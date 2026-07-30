// supabase/functions/odeme-webhook/index.ts
//
// Tek webhook alici, iki saglayici: https://<proje>.functions.supabase.co/odeme-webhook/paytr
// ve .../odeme-webhook/lemonsqueezy olarak cagrilir (saglayici URL yolundan ayirt edilir).
//
// Ortam degiskenleri (Supabase Dashboard > Edge Functions > Secrets):
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY  (otomatik saglanir)
//   LEMONSQUEEZY_WEBHOOK_SECRET
//   PAYTR_MERCHANT_KEY, PAYTR_MERCHANT_SALT
//
// ONEMLI: PayTR dogrulamasi iki katmanlidir:
//   1) Hash dogrulama (asagida uygulandi) -- PayTR'nin standart bildirim
//      URL'si icin bilinen formul: base64(HMAC-SHA256(merchant_oid + merchant_salt
//      + status + total_amount, merchant_key)). Bu, PayTR'nin CORE odeme
//      bildirimi icin gecerlidir.
//   2) Olay alanlarinin eslenmesi (paytrNormallestir) -- PayTR'nin abonelik/
//      tekrarlayan odeme urunune ozel alan adlari (subscription id, durum
//      metinleri vb.) surumden surume degisebiliyor; canli entegrasyon
//      oncesi guncel PayTR dokumantasyonuyla teyit edilmelidir. Asagida
//      iskelet birakildim, dogru alan adlarini oraya doldur.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const lemonsqueezySecret = Deno.env.get('LEMONSQUEEZY_WEBHOOK_SECRET') ?? ''
const paytrMerchantKey = Deno.env.get('PAYTR_MERCHANT_KEY') ?? ''
const paytrMerchantSalt = Deno.env.get('PAYTR_MERCHANT_SALT') ?? ''

const supabase = createClient(supabaseUrl, serviceRoleKey)

Deno.serve(async (req: Request) => {
  const url = new URL(req.url)
  const saglayici = url.pathname.includes('paytr')
    ? 'paytr'
    : url.pathname.includes('lemonsqueezy')
      ? 'lemonsqueezy'
      : null

  if (!saglayici) {
    return new Response('Bilinmeyen saglayici yolu', { status: 404 })
  }

  // PayTR bildirimi form-encoded (application/x-www-form-urlencoded) gonderir,
  // LemonSqueezy ise JSON govde + imza header'i kullanir -- ikisini ayri ayri okuyoruz.
  let alanlar: Record<string, string> = {}
  let rawBody = ''

  if (saglayici === 'paytr') {
    rawBody = await req.text()
    alanlar = Object.fromEntries(new URLSearchParams(rawBody))

    const gecerli = await paytrHashDogrula(alanlar, paytrMerchantKey, paytrMerchantSalt)
    if (!gecerli) {
      console.error('PayTR hash dogrulamasi basarisiz')
      // PayTR, "OK" donmezsen bildirimi tekrar tekrar gonderir -- basarisiz
      // dogrulamada da 400 donup birakiyoruz, sahte veriyi islemiyoruz.
      return new Response('PAYTR notification failed: hash mismatch', { status: 400 })
    }
  } else {
    rawBody = await req.text()
    const imza = req.headers.get('X-Signature') ?? ''
    const gecerli = await lemonsqueezyImzaDogrula(rawBody, imza, lemonsqueezySecret)
    if (!gecerli) {
      console.error('LemonSqueezy imza dogrulamasi basarisiz')
      return new Response('Gecersiz imza', { status: 401 })
    }
    try {
      alanlar = JSON.parse(rawBody)
    } catch {
      return new Response('Gecersiz govde (JSON degil)', { status: 400 })
    }
  }

  const saglayiciOlayId = saglayici === 'paytr'
    ? String(alanlar['merchant_oid'] ?? '')
    : String((alanlar as any)?.meta?.event_id ?? (alanlar as any)?.data?.id ?? '')

  if (!saglayiciOlayId) {
    return new Response('Olay kimligi bulunamadi', { status: 400 })
  }

  // --- Idempotenlik: ayni olay iki kez islenmesin ---
  const { data: mevcutKayit } = await supabase
    .from('webhook_olaylari')
    .select('id, islendi_mi')
    .eq('saglayici_olay_id', saglayiciOlayId)
    .maybeSingle()

  if (mevcutKayit?.islendi_mi) {
    // PayTR "OK" metnini bekliyor, LemonSqueezy govde icerigine bakmiyor --
    // ikisi icin de duz metin donmek yeterli ve guvenli.
    return new Response('OK', { status: 200 })
  }

  const olayTipi = saglayici === 'paytr'
    ? `paytr_status_${alanlar['status'] ?? 'bilinmiyor'}`
    : String((alanlar as any)?.meta?.event_name ?? 'bilinmiyor')

  const { data: kayit, error: kayitHatasi } = await supabase
    .from('webhook_olaylari')
    .upsert(
      { saglayici, olay_tipi: olayTipi, saglayici_olay_id: saglayiciOlayId, payload: alanlar },
      { onConflict: 'saglayici_olay_id' },
    )
    .select()
    .single()

  if (kayitHatasi || !kayit) {
    console.error('webhook_olaylari kayit hatasi', kayitHatasi)
    return new Response('Kayit hatasi', { status: 500 })
  }

  try {
    await olayiIsle(saglayici, olayTipi, alanlar)
    await supabase
      .from('webhook_olaylari')
      .update({ islendi_mi: true, islendi_tarih: new Date().toISOString() })
      .eq('id', kayit.id)
  } catch (e) {
    console.error('Is mantigi hatasi', e)
    await supabase
      .from('webhook_olaylari')
      .update({ hata_mesaji: String(e) })
      .eq('id', kayit.id)
    // PayTR icin bile 200/OK donmek cogu zaman daha guvenli (surekli
    // tekrar denemeyi onlemek icin); hatayi hata_mesaji alaninda tutup
    // ayrica izliyoruz.
    return new Response(saglayici === 'paytr' ? 'OK' : 'Isleme hatasi', {
      status: saglayici === 'paytr' ? 200 : 500,
    })
  }

  return new Response('OK', { status: 200 })
})

// =====================================================================
// Is mantigi: saglayiciya ozel payload'i ortak modele cevirip
// abonelikler / odeme_gecmisi tablolarini gunceller.
// =====================================================================

async function olayiIsle(saglayici: string, olayTipi: string, alanlar: Record<string, unknown>) {
  const norm = saglayici === 'paytr'
    ? paytrNormallestir(olayTipi, alanlar)
    : lemonsqueezyNormallestir(olayTipi, alanlar)

  if (!norm) return // ilgilenmedigimiz bir olay tipi, sessizce gec

  if (norm.durum) {
    await supabase
      .from('abonelikler')
      .update({
        durum: norm.durum,
        donem_bitis: norm.donemBitis ?? null,
        saglayici_musteri_id: norm.saglayiciMusteriId ?? null,
        updated_at: new Date().toISOString(),
      })
      .eq('isletme_id', norm.isletmeId)
      .eq('saglayici_abonelik_id', norm.saglayiciAbonelikId)
  }

  if (norm.odeme) {
    await supabase.from('odeme_gecmisi').insert({
      isletme_id: norm.isletmeId,
      tutar: norm.odeme.tutar,
      para_birimi: norm.odeme.paraBirimi,
      durum: norm.odeme.durum,
      saglayici_islem_id: norm.odeme.islemId,
      fatura_url: norm.odeme.faturaUrl ?? null,
    })
  }
}

type NormalizeSonuc = {
  isletmeId: string
  saglayiciAbonelikId?: string
  saglayiciMusteriId?: string
  durum?: string
  donemBitis?: string
  odeme?: { tutar: number; paraBirimi: string; durum: string; islemId: string; faturaUrl?: string }
} | null

// NOT: checkout baslatilirken merchant_oid icine "islemetme_id-siparis_no"
// gibi bir kod gomulmesi onerilir (ornegin `${isletmeId}-${Date.now()}`),
// boylece webhook geldiginde hangi isletmeye ait oldugunu buradan
// cozebilirsin. asagidaki satir bu varsayimla yazildi -- kendi checkout
// olusturma kodunla tutarli olacak sekilde uyarla.
function paytrNormallestir(olayTipi: string, alanlar: Record<string, unknown>): NormalizeSonuc {
  const merchantOid = String(alanlar['merchant_oid'] ?? '')
  const isletmeId = merchantOid.split('-')[0]
  if (!isletmeId) return null

  const status = String(alanlar['status'] ?? '')
  const tutarKurus = Number(alanlar['total_amount'] ?? 0)

  if (status === 'success') {
    return {
      isletmeId,
      durum: 'aktif',
      odeme: {
        tutar: tutarKurus / 100,
        paraBirimi: 'TRY',
        durum: 'basarili',
        islemId: merchantOid,
      },
    }
  }

  if (status === 'failed') {
    return {
      isletmeId,
      odeme: {
        tutar: tutarKurus / 100,
        paraBirimi: 'TRY',
        durum: 'basarisiz',
        islemId: merchantOid,
      },
    }
  }

  // TODO: PayTR'nin tekrarlayan odeme/abonelik urunune ozel olay
  // tiplerini (abonelik yenilendi, abonelik iptal edildi vb.) burada ekle.
  return null
}

// NOT: alan adlari (meta.custom_data, data.attributes.status, vb.)
// LemonSqueezy'nin guncel webhook dokumantasyonuna gore dogrulanmalidir.
function lemonsqueezyNormallestir(olayTipi: string, payload: any): NormalizeSonuc {
  const isletmeId = payload?.meta?.custom_data?.isletme_id
  if (!isletmeId) return null

  if (olayTipi === 'subscription_created' || olayTipi === 'subscription_updated' || olayTipi === 'subscription_cancelled') {
    const durumMetni = payload?.data?.attributes?.status
    const durum = durumMetni === 'active' ? 'aktif'
      : durumMetni === 'cancelled' || durumMetni === 'expired' ? 'iptal_edildi'
      : durumMetni === 'past_due' ? 'odeme_gecikti'
      : 'suresi_doldu'
    return {
      isletmeId,
      durum,
      donemBitis: payload?.data?.attributes?.renews_at,
      saglayiciMusteriId: String(payload?.data?.attributes?.customer_id ?? ''),
      saglayiciAbonelikId: String(payload?.data?.id ?? ''),
    }
  }

  if (olayTipi === 'subscription_payment_success') {
    return {
      isletmeId,
      saglayiciAbonelikId: String(payload?.data?.attributes?.subscription_id ?? ''),
      odeme: {
        tutar: (payload?.data?.attributes?.total ?? 0) / 100,
        paraBirimi: payload?.data?.attributes?.currency ?? 'EUR',
        durum: 'basarili',
        islemId: String(payload?.data?.id ?? ''),
      },
    }
  }

  return null
}

// =====================================================================
// PayTR hash dogrulama -- standart bildirim URL formulu:
// base64( HMAC-SHA256( merchant_oid + merchant_salt + status + total_amount,
//                       merchant_key ) )
// Bu deger, PayTR'nin gonderdigi "hash" alaniyla birebir eslesmelidir.
// =====================================================================

async function paytrHashDogrula(
  alanlar: Record<string, string>,
  merchantKey: string,
  merchantSalt: string,
): Promise<boolean> {
  if (!merchantKey || !merchantSalt) return false

  const { merchant_oid, status, total_amount, hash } = alanlar
  if (!merchant_oid || !status || !total_amount || !hash) return false

  const hashStr = `${merchant_oid}${merchantSalt}${status}${total_amount}`
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(merchantKey),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  )
  const mac = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(hashStr))
  const hesaplanan = btoa(String.fromCharCode(...new Uint8Array(mac)))
  return sabitSureliKarsilastir(hesaplanan, hash)
}

// =====================================================================
// LemonSqueezy imza dogrulama (HMAC-SHA256, raw govde uzerinden)
// =====================================================================

async function lemonsqueezyImzaDogrula(rawBody: string, imza: string, secret: string): Promise<boolean> {
  if (!secret || !imza) return false
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  )
  const mac = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(rawBody))
  const hex = [...new Uint8Array(mac)].map((b) => b.toString(16).padStart(2, '0')).join('')
  return sabitSureliKarsilastir(hex, imza)
}

function sabitSureliKarsilastir(a: string, b: string): boolean {
  if (a.length !== b.length) return false
  let sonuc = 0
  for (let i = 0; i < a.length; i++) sonuc |= a.charCodeAt(i) ^ b.charCodeAt(i)
  return sonuc === 0
}
