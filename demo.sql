-- INTRODUCTION
-- Working with JSON and JSONB
-- * JSON: json data type validates the JSON document, however it is stored as plain text.
-- * JSONB: jsonb is parsed and stored in binary format.

-- Pros & Cons:
-- * Although during insertions using json can result in a small benefit, if you want to access the document later it will be more costly.
-- * What makes jsonb even more attractive is that many functions and operators only exist for the binary representation.

-- DISPLAYING AND CREATING JSON DOCUMENTS

-- There are two lines featuring three columns each.
-- Note row_to_json function turns each row into a separate JSON document.
SELECT row_to_json(x) FROM (VALUES (1, 2, 3), (4, 5, 6)) AS x;

-- If we want the entire result to be a single JSON document, json_agg function needs to be used.
SELECT json_agg(x) FROM (VALUES (1, 2, 3), (4, 5, 6)) AS x;

-- NOTE:
-- There is a + at the end of the line. This is not part of the JSON document, but it is added
-- by psql to indicate the line break. As application developers, this is not an issue for us.

-- It is easier to preformat a JSON document. The jsonb_pretty function helps to properly format the output.
SELECT jsonb_pretty(json_agg(x)::jsonb) FROM (VALUES (1, 2, 3), (4, 5, 6)) AS x;


-- TURNING JSON DOCUMENTS INTO ROWS

-- JSON does not end up in a database by itself – we have to put it there.
-- We may have to map a document to an existing table, json_populate_record function maps suitable JSON to the table.
-- Note that using NULL::demo1 is a shorthand way to give PostgreSQL the structure it needs
-- to map JSON data into a row format without needing an actual existing record from demo1.
-- If you have a table that matches your JSON document, at least partially, you are mostly done
INSERT INTO demo1 SELECT * FROM json_populate_record(NULL::demo1, '{"x":54,"y":65}');


-- ACCESSING A JSON DOCUMENT

-- Inserting the data we need for further demonstration
INSERT INTO demo2 VALUES (1,
    '{
         "product": "pigments",
         "colors": {
         "red": "#FF0000",
         "blue": "#0000FF",
         "green": "#008000"
         }
    }');

-- The query retrieves JSON data from the doc column in the demo2 table, formatting it for readability using jsonb_pretty.
-- It displays both the entire JSON document and a specific colors field within the JSON in a structured, indented format.
-- The -> operator will help us to find a subtree and return this part.
SELECT jsonb_pretty(doc), jsonb_pretty(doc -> 'colors') FROM demo2;

-- If we dig one level deeper and see what description there is for red:
SELECT jsonb_pretty(doc -> 'colors' -> 'red') FROM demo2;

-- As you can see, we can just call the operator again and apply it to the mini-JSON document.
-- Note that the data is quoted, because the data is of type jsonb, think of it still as a little json document.
SELECT pg_typeof(doc -> 'product') FROM demo2;

-- If we want to have the real value of the entry, we have to use the ->> operator, where the type will be text.
SELECT doc -> 'product', doc ->> 'product' FROM demo2;

-- The data type has a couple of implications: if you are looking for other data types inside the JSON,
-- you have to cast those fields to the data type you need (integer, numeric, date, etc.).
-- Consider the following example, where colors is object and product is string.
-- From a JSON point of view, we are dealing with objects (if we are talking about a subtree)
-- and a JSON data type at the lowest level
SELECT jsonb_typeof(doc -> 'colors'), jsonb_typeof(doc -> 'product') FROM demo2;

-- In such cases we often need to loop over elements:
SELECT jsonb_each(doc -> 'colors') FROM demo2;

-- This query also uses jsonb_each, but it expands the results using .*, so each part of the composite type (i.e., key and value) is shown in a separate column.
-- However, we can expand on this type and return those elements as separate fields
SELECT (jsonb_each(doc -> 'colors')).* FROM demo2;

-- Note that the value is still a mini-JSON document,
-- which is important because we might be dealing with a subtree in need of further processing.
-- If you want to loop over all elements and extract text, consider the following code sample:
SELECT (jsonb_each_text(doc -> 'colors')).* FROM demo2;

-- If you need to just extract the keys in the document or subtree, jsonb_object_keys is used:
SELECT jsonb_object_keys(doc) FROM demo2;

-- @ operator is used for filtering
SELECT doc from demo2 where doc @> '{"product": "pigments"}'::jsonb