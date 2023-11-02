# Vertica 
##### HL_Join.sql
Пример оптимизации self join:

* Ко всем источникам цепочки сборки промежуточных таблиц подготовлены суперпроекции, 
оптимизированные сортировкой.

* Значения на выходе таблицы nk.br_cert_AVG_MAXp округлены до 2-х знаков после запятой (для 
облегчения последующих вычислений обрезаны "хвосты"). Для уменьшения расхода памяти эти и их производные поля ограничены до минимальных значений NUMERIC.

* Промежуточные таблицы nk.br_cert_JOINp_old_code и nk.br_cert_min_maxp_old_code преобразованы в одну nk.br_cert_JOINp, в джоин таблицы самой на себя (self join) добавлено отсечение значений, которые впоследствии использоваться не будут:
  
  JOIN ...
  
  ON ...

  AND   (

       (CASE WHEN a.MAX_weight >= b.MAX_weight THEN b.MAX_weight / a.MAX_weight ELSE a.MAX_weight / b.MAX_weight END) BETWEEN 0.96 AND 1

    OR

       (CASE WHEN a.AVG_weight >= b.AVG_weight THEN b.AVG_weight / a.AVG_weight ELSE a.AVG_weight / b.AVG_weight END) BETWEEN 0.96 AND 1

       )

  В результате этого устранена излишняя запись во временные таблицы соединения и результатов на диск.  

  Тайминги сборки и объем временных таблиц до оптимизации:
  nk.br_cert_JOINp_old_code           487min ~ 50 mlrd row
  nk.br_cert_min_maxp_old_code        247min 41 mlrd row
  nk.br_cert_row_nump_old_code        706min 19 mlrd row

  Тайминги сборки и объем временных таблиц после оптимизации:
  nk.br_cert_JOINp                    28min 1.3 mlrd row
  nk.br_cert_row_nump                 24min

  Итоговое время полной пересборки данных на промежутке nk.br_cert_JOINp -  nk.br_cert_row_nump уменьшено  с 1440 мин до 52 мин, то есть в 27 раз.

Подобная ситуация встречается не часто, но на примере хорошо видно влияние максимально возможной фильтрации в джоине больших таблиц и перенос вычислений в оперативную память без слива результатов на диск.
   
