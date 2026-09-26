-- 169c: recete_asamalari ve asama_malzemeleri tablolarinin TAM sutun
-- listesi -- Giresun/Rize duzeltmesini yazmadan once semayi
-- tahmin etmemek icin.
select table_name, column_name, data_type, is_nullable
from information_schema.columns
where table_name in ('recete_asamalari', 'asama_malzemeleri')
order by table_name, ordinal_position;
