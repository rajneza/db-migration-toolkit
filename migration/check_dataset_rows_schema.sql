-- Check dataset_rows table schema to find array columns
SELECT 
    column_name,
    data_type,
    udt_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'dataset_rows'
ORDER BY ordinal_position;
