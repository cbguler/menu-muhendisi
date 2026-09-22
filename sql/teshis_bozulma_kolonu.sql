select column_name
from information_schema.columns
where table_name = 'malzemeler'
  and (column_name ilike '%bozulma%' or column_name ilike '%sure%');
