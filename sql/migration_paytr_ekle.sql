-- migration_paytr_ekle.sql
-- abonelik_ve_odeme_altyapisi.sql'i daha once calistirdiysan, sadece bunu calistir.
-- Yeni kuruyorsan buna gerek yok -- ana dosya zaten guncellendi.

alter table abonelikler
  drop constraint if exists abonelikler_odeme_saglayici_check;

alter table abonelikler
  add constraint abonelikler_odeme_saglayici_check
  check (odeme_saglayici in ('paytr','iyzico','lemonsqueezy','paddle','stripe','manuel'));
