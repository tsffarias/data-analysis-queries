/* 
** QUERIES GEOGRAFICAS **
*/

/* Bases de dados Bigquery Public Data */
/* Query com informações geograficas de rotas de bicicletas em San Francisco + Calculo de distancia em metros e velocidade média */

select  
  trip_id,
  /* infos da estação de partida */
  start_station_latitude,
  start_station_longitude,
  start_station_geom,
  st_geogpoint(start_station_longitude, start_station_latitude) as ponto_geografico_start,
  /* infos da estação de chegada */
  end_station_latitude,
  end_station_longitude,
  end_station_geom,
  st_geogpoint(end_station_longitude, end_station_latitude) as ponto_geografico_end,
  /* distancia e velocidade média (m/s) */
  round(st_distance(start_station_geom, end_station_geom), 0) as distancia_metros,
  round(st_distance(start_station_geom, end_station_geom) / duration_sec, 0) as velocidade_media,
  /* st_x e st_y */
  st_x(start_station_geom) as longitude,
  st_y(start_station_geom) as latitude,
  /* st_makeline é usado para colocar linhas em uma visualização de Mapa */
  st_makeline(start_station_geom, end_station_geom) as rota
from `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` 
where start_station_latitude is not null and start_station_longitude is not null
  and end_station_latitude is not null and end_station_longitude is not null
  and round(st_distance(start_station_geom, end_station_geom), 0) > 0
order by rand() # pegando dados aleatorios
limit 100;

/* Query com 10 localizações geograficas de crimes usando dataset publico austin_crime  */
/* Cria pontos geográficos */
/* Pega 10 crimes aleatorios */
/* A partir de um ponto geografico do mcdonalds da cidade, calcula a distancia (em km) entre o ponto do crime/incidente até o ponto geografico do mcdonalds */
/* Crie também as rotas de cada incidente á cordenada (linhas de rota) */

SELECT 
  unique_key,
  /* infos dos crimes */
  latitude,
  longitude,
  st_geogpoint(longitude, latitude) as ponto_geografico_crime,
  clearance_status,
  description,
  year,
  /* infos do mcdonalds 30.2723734,-97.6981411 */
  ST_GEOGPOINT(-97.6981411, 30.2723734) AS ponto_geografico_mcdonalds,
  /* distancia */
  round(ST_DISTANCE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-97.6981411, 30.2723734))/1000, 2) as distancia,
  /* criando linhas de rota */
  ST_MAKELINE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-97.6981411, 30.2723734)) AS rota
from `bigquery-public-data.austin_crime.crime` 
where latitude is not null and longitude is not null
order by rand() # pegando dados aleatorios
limit 10


/* Calcule a mínima e a máxima distância do resultado da query acima. */
WITH dist as (
  select
    unique_key,
    /* infos dos incidentes */
    latitude,
    longitude,
    ST_GEOGPOINT(longitude, latitude) AS ponto_geografico_incidente,
    /* infos do mcdonalds 30.2723734,-97.6981411 */
    ST_GEOGPOINT(-97.6981411, 30.2723734) AS ponto_geografico_mcdonalds,
    /* distancia */
    round(ST_DISTANCE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-97.6981411, 30.2723734))/1000, 2) as distancia,
    /* criando linhas de rota */
    ST_MAKELINE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-97.6981411, 30.2723734)) AS rota
  from bigquery-public-data.austin_crime.crime
  where latitude is not null 
    and longitude is not null
  order by rand()
  limit 10)

select
  min(distancia) as minimo,
  max(distancia) as maximo
from dist;