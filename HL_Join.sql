 
--********************************************************
--*********     OLD CODE    ******************************
--********************************************************

--0.78s   - AVG::INT 3.2s  -- 1.7s
INSERT INTO nk.br_cert_AVG_MAXp_old_code
(ent_region_id, ent_id, product_id, AVG_weight, MAX_weight, count_part)
SELECT   ent_region_id, ent_id, product_id,  AVG(weight)::int AS AVG_weight,  MAX(weight) AS MAX_weight, MAX(count_part) as count_part
FROM nk.br_cert_SUM_wp
GROUP BY ent_region_id, ent_id,  product_id


-------115m 57s 1023Gb   36.545 mlrd row (DEV)
---------- 487m 21s 1.4Tb (PROD)
INSERT INTO nk.br_cert_JOINp_old_code
(ent_region_id,
 product_id,
 count_part,
 a_ent_id,
 b_ent_id,
 a_AVG_weight,
 a_MAX_weight,
 b_AVG_weight,
 b_MAX_weight)
SELECT
 a.ent_region_id,
 a.product_id,
 a.count_part,
 a.ent_id as a_ent_id,
 b.ent_id as b_ent_id,
 a.AVG_weight as a_AVG_weight,
 a.MAX_weight as a_MAX_weight,
 b.AVG_weight as b_AVG_weight,
 b.MAX_weight as b_MAX_weight
FROM nk.br_cert_AVG_MAXp_old_code a
JOIN nk.br_cert_AVG_MAXp_old_code b
ON a.ent_region_id = b.ent_region_id
AND a.ent_id != b.ent_id
AND a.product_id = b.product_id


--------91m 2s 1.6Tb (DEV)
--247m  2.26Tb  41.266.980.968row (PROD)
INSERT INTO nk.br_cert_min_maxp_old_code
(ent_region_id,
 product_id,
 count_part,
 a_ent_id,
 b_ent_id,
 a_AVG_weight,
 a_MAX_weight,
 b_AVG_weight,
 b_MAX_weight,
 maxMAX,
 minMAX,
 maxAVG,
 minAVG)
SELECT
 ent_region_id,
 product_id,
 count_part,
 a_ent_id,
 b_ent_id,
 a_AVG_weight,
 a_MAX_weight,
 b_AVG_weight,
 b_MAX_weight,
 CASE WHEN a_MAX_weight >= b_MAX_weight THEN a_MAX_weight ELSE b_MAX_weight END AS maxMAX,
 CASE WHEN a_MAX_weight <  b_MAX_weight THEN a_MAX_weight ELSE b_MAX_weight END AS minMAX,
 CASE WHEN a_AVG_weight >= b_AVG_weight THEN a_AVG_weight ELSE b_AVG_weight END AS maxAVG,
 CASE WHEN a_AVG_weight <  b_AVG_weight THEN a_AVG_weight ELSE b_AVG_weight END AS minAVG
FROM nk.br_cert_JOINp_old_code
WHERE a_AVG_weight > 0
AND   a_MAX_weight > 0
AND   b_AVG_weight > 0
AND   b_MAX_weight > 0


---- 706m 2s 1475Gb 19.7 mlrd
INSERT  INTO nk.br_cert_row_nump_old_code
(ent_region_id,
 product_id,
 a_ent_id,
 b_ent_id,
 a_AVG_weight,
 a_MAX_weight,
 b_AVG_weight,
 b_MAX_weight,
 maxMAX,
 minMAX,
 maxAVG,
 minAVG,
 count_part,
 koefMAX,
 koefAVG,
 row_num_koefMAX,
 row_num_koefAVG)
SELECT ent_region_id, product_id, a_ent_id, b_ent_id, a_AVG_weight, a_MAX_weight, b_AVG_weight, b_MAX_weight, maxMAX, minMAX, maxAVG, minAVG, count_part,
       minMAX / maxMAX as koefMAX,
       minAVG / maxAVG as koefAVG,
       ROW_NUMBER() OVER (PARTITION BY ent_region_id, product_id, a_ent_id ORDER BY (minMAX / maxMAX) DESC) AS row_num_koefMAX,
       ROW_NUMBER() OVER (PARTITION BY ent_region_id, product_id, a_ent_id ORDER BY (minAVG / maxAVG) DESC) AS row_num_koefAVG
FROM nk.br_cert_min_maxp_old_code
WHERE maxMAX > 0
AND   maxAVG > 0





--********************************************************
--*********     NEW CODE    ******************************
--********************************************************


--0m08s
INSERT INTO nk.br_cert_AVG_MAXp
(ent_region_id,
 ent_id,
 product_id,
 AVG_weight,
 MAX_weight,
 count_part)
SELECT   ent_region_id, ent_id, product_id,
         ROUND( AVG(weight), 2) AS AVG_weight,
         ROUND( MAX(weight), 2) AS MAX_weight,
         MAX(count_part) as count_part
FROM nk.br_cert_SUM_wp
GROUP BY ent_region_id, ent_id,  product_id


-------115m 57s 1023Gb   36.545 mlrd row (DEV)
--------91m 2s 1.6Tb (DEV)
---------- 487m 21s 1.4Tb (PROD)
--247m  2.26Tb  41.266.980.968row (PROD)
-- 28m25s 12.12.2021   ||| 1362040198 row (new code)
INSERT INTO nk.br_cert_JOINp
(ent_region_id,
 product_id,
 count_part,
 a_ent_id,
 b_ent_id,
 a_MAX_weight,
 b_MAX_weight,
 maxMAX,
 minMAX,
 maxAVG,
 minAVG)
SELECT
 a.ent_region_id,
 a.product_id,
 a.count_part,
 a.ent_id as a_ent_id,
 b.ent_id as b_ent_id,
 a.AVG_weight as a_AVG_weight,
 a.MAX_weight as a_MAX_weight,
 b.AVG_weight as b_AVG_weight, b.MAX_weight as b_MAX_weight,
 CASE WHEN a.MAX_weight >= b.MAX_weight THEN a.MAX_weight ELSE b.MAX_weight END AS maxMAX,
 CASE WHEN a.MAX_weight <  b.MAX_weight THEN a.MAX_weight ELSE b.MAX_weight END AS minMAX,
 CASE WHEN a.AVG_weight >= b.AVG_weight THEN a.AVG_weight ELSE b.AVG_weight END AS maxAVG,
 CASE WHEN a.AVG_weight <  b.AVG_weight THEN a.AVG_weight ELSE b.AVG_weight END AS minAVG
FROM nk.br_cert_AVG_MAXp a
JOIN nk.br_cert_AVG_MAXp b
ON a.ent_region_id = b.ent_region_id
AND a.ent_id != b.ent_id
AND a.product_id = b.product_id
AND   a.AVG_weight > 0
AND   a.MAX_weight > 0
AND   b.AVG_weight > 0
AND   b.MAX_weight > 0
AND   (
       (CASE WHEN a.MAX_weight >= b.MAX_weight THEN b.MAX_weight / a.MAX_weight ELSE a.MAX_weight / b.MAX_weight END) BETWEEN 0.96 AND 1
    OR
       (CASE WHEN a.AVG_weight >= b.AVG_weight THEN b.AVG_weight / a.AVG_weight ELSE a.AVG_weight / b.AVG_weight END) BETWEEN 0.96 AND 1
       )


---- 706m 2s 1475Gb 19.7 mlrd (PROD)
--24m5s (new code)
INSERT INTO nk.br_cert_row_nump  
(ent_region_id,
 product_id,
 a_ent_id,
 b_ent_id,
 a_AVG_weight,
 a_MAX_weight,
 b_AVG_weight,
 b_MAX_weight,
 maxMAX,
 minMAX,
 maxAVG,
 minAVG,
 count_part,
 koefMAX,
 koefAVG,
 row_num_koefMAX,
 row_num_koefAVG)
SELECT ent_region_id, product_id, a_ent_id, b_ent_id, a_AVG_weight, a_MAX_weight, b_AVG_weight, b_MAX_weight, maxMAX, minMAX, maxAVG, minAVG, count_part,
       minMAX / maxMAX as koefMAX,
       minAVG / maxAVG as koefAVG,
       ROW_NUMBER() OVER (PARTITION BY ent_region_id, product_id, a_ent_id ORDER BY (minMAX / maxMAX) DESC) AS row_num_koefMAX,
       ROW_NUMBER() OVER (PARTITION BY ent_region_id, product_id, a_ent_id ORDER BY (minAVG / maxAVG) DESC) AS row_num_koefAVG
FROM nk.br_cert_JOINp
