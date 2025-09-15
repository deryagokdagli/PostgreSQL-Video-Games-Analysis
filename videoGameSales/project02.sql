CREATE VIEW video_games AS
SELECT
    COALESCE(NULLIF(name, ''), 'Unknown') AS name,
    COALESCE(NULLIF(developer, ''), 'Unknown') AS developer,
    COALESCE(NULLIF(genre, ''), 'Unknown') AS genre,
    COALESCE(NULLIF(publisher, ''), 'Unknown') AS publisher,
    COALESCE(NULLIF(platform, ''), 'Unknown') AS platform,
    COALESCE(NULLIF(rating, ''), 'Unknown') AS rating,
    COALESCE(global_sales, 0) AS global_sales,
    COALESCE(na_sales, 0) AS na_sales,
    COALESCE(eu_sales, 0) AS eu_sales,
    COALESCE(jp_sales, 0) AS jp_sales,
    COALESCE(other_sales, 0) AS other_sales,
    COALESCE(critic_score, 0) AS critic_score,
    COALESCE(critic_count, 0) AS critic_count,
    COALESCE(user_score, 0) AS user_score,
    COALESCE(user_count, 0) AS user_count,
    COALESCE(year_of_release, 0) AS year_of_release
FROM video_games_sales;

--1.0 
--1.1 & 1.2 En çok satan oyunlar & publisher’lar
SELECT 
	 name,
	 global_sales
FROM video_games
ORDER BY 2 DESC;
--
SELECT 
	publisher,
	sum(global_sales)
FROM video_games
GROUP BY 1
ORDER BY 2 DESC;

--1.3 Yıllara göre satış trendi (en yüksek,en düşük) 
--where filtrelemesi yaptık çünkü iki değerde nulldı biz 0 ile doldurmuştuk 
SELECT 
	year_of_release as year,
	sum(global_sales) as total_global_sales
FROM video_games
WHERE year_of_release <> 0 and global_sales <> 0 
GROUP BY 1
ORDER BY 2 DESC;

--1.4 Platform bazlı satış karşılaştırması 
SELECT
	platform,
	sum(global_sales) AS total_global_sales
FROM video_games
GROUP BY 1
ORDER BY 2 DESC;

--1.5 Genre bazlı satış analizi
SELECT
	genre,
	sum(global_sales) AS total_global_sales
FROM video_games
GROUP BY 1
ORDER BY 2 DESC;

--1.6 Puan ve Satış İlişkisi
SELECT
	critic_score,
	sum(global_sales) AS total_global_sales
FROM video_games
WHERE critic_score <> 0
GROUP BY 1
ORDER BY 1 DESC;

--1.7 Hangi tür oyunlar hangi bölgede daha çok satıyor? 
SELECT  
	genre,
	sum(na_sales) as total_na_sales,
	sum(eu_sales) as total_eu_sales,
	sum(jp_sales) as total_jp_sales,
	sum(other_sales) as total_other_sales
FROM video_games
WHERE genre <> 'Unknown'
GROUP BY 1;

--1.8 Her genre içinde oyunları, Kuzey Amerika satışlarına göre büyükten küçüğe sırala ve sıra numarasını göster. dikkat: aynı oyun farklı platformda yayınlanmışsa çoklar
SELECT
    name,
    genre,
    sum(na_sales) as total_na_sales,
    ROW_NUMBER() OVER (PARTITION BY genre ORDER BY sum(na_sales) DESC) AS rank_in_genre
FROM video_games
GROUP BY 1,2;

--1.9 Her yıl için en çok satan yayıncının (publisher) toplam satışlarını bul ve o yıl içindeki sırasını (RANK) göster.
WITH publisher_sales AS (
    SELECT
        year_of_release,
        publisher,
        SUM(global_sales) AS total_sales
    FROM video_games
    WHERE year_of_release <> 0
    GROUP BY 1,2
)
SELECT
    year_of_release,
    publisher,
    total_sales,
    RANK() OVER (PARTITION BY year_of_release ORDER BY total_sales DESC) AS rank_in_year
FROM publisher_sales
ORDER BY 1 DESC, 4;

--2.0 Her oyunun satışını, ait olduğu genre’nin toplam satışına oran (yüzde) olarak göster.
SELECT 
	genre,
	global_sales,
	sum(global_sales) over (PARTITION BY genre) as genre_total,
	round(100 * global_sales / NULLIF(sum(global_sales) over (PARTITION BY genre),0)) as  percent_of_genre
FROM video_games
ORDER BY 1,4;

--2.1 Her publisher için, kendi oyunlarının ortalama satışını bul. Sonra, her oyunun satışının bu ortalamanın üzerinde mi altında mı olduğunu göster.
SELECT  
	name,
	publisher,
	global_sales,
	avg(global_sales) over (PARTITION BY publisher) as avg_sales_per_publisher, --kendi oyunlarının ortalama satışı
	CASE
		WHEN global_sales > avg(global_sales) over (PARTITION BY publisher) then 'Above Average'
		WHEN global_sales < avg(global_sales) over (PARTITION BY publisher) then 'Below Average'
	END AS message
FROM video_games
ORDER BY 3 DESC;

--2.2 Her oyun için, küresel toplam satışını (na + eu + jp + other) hesapla. Sonra, bu değerin kendi yılındaki en yüksek global satışa oranını bul.
SELECT 
	name,
	year_of_release,
	na_sales + eu_sales + jp_sales + other_sales as total_global_sales,
	max(na_sales + eu_sales + jp_sales + other_sales) OVER (PARTITION BY year_of_release) as max_sales_in_year,
	round((100.0 * (na_sales + eu_sales + jp_sales + other_sales) / NULLIF(max(na_sales + eu_sales + jp_sales + other_sales) OVER (PARTITION BY year_of_release),0))::numeric,2) as percent_of_year_max
FROM video_games
ORDER BY 2 DESC;

--2.3 Her yayıncının en çok hangi platformda satış yaptığı nedir?
WITH publisher_platform_sales as(
SELECT
	publisher,
	platform,
	sum(global_sales) as total_sales,
	ROW_NUMBER() over (PARTITION BY publisher ORDER BY sum(global_sales)DESC) as rn
FROM video_games
GROUP BY 1,2
)
SELECT
	publisher,
	platform,
	total_sales
FROM publisher_platform_sales
WHERE rn = 1
ORDER BY 3 DESC;

--2.4 Yıllara göre en başarılı ve en başarısız yayıncılar kimlerdir?
WITH yearly_publisher_sales AS (
SELECT 
	year_of_release,
	publisher,
	sum(global_sales) as total_sales
FROM video_games
WHERE year_of_release <> 0
GROUP BY 1,2
),
ranked_publishers AS (
SELECT 
	year_of_release,
	publisher,
	total_sales,
	RANK() OVER (PARTITION BY year_of_release ORDER BY total_sales DESC) AS rank_desc,
	RANK() OVER (PARTITION BY year_of_release ORDER BY total_sales ASC) AS rank_asc 
FROM yearly_publisher_sales
)

SELECT 
	year_of_release,
	publisher,
	total_sales,
	CASE 
		WHEN rank_desc = 1 THEN 'Most Succesfull'
		WHEN rank_asc = 1 THEN 'Least Succesfull'
	END AS statuss
FROM ranked_publishers
WHERE rank_desc = 1 or rank_asc = 1
ORDER BY 1 DESC, statuss;

--2.5 Her türdeki oyunların ortalama critic_score ve user_score nedir?
SELECT 
	genre,
	round(avg(critic_score)) as avg_critic_score,
	round(avg(user_score)) as avg_user_score
FROM video_games
GROUP BY 1
HAVING avg(critic_score) <> 0 and avg(user_score) <> 0;

--2.6 Critic score ve user score’a göre oyunları Above/Below Average kategorize et.
SELECT
    name,
    genre,
    critic_score,
    user_score,
    AVG(critic_score) OVER (PARTITION BY genre) AS avg_critic_score_genre,
    AVG(user_score) OVER (PARTITION BY genre) AS avg_user_score_genre,
    CASE
        WHEN critic_score > AVG(critic_score) OVER (PARTITION BY genre) THEN 'Critic Above Average'
        WHEN critic_score < AVG(critic_score) OVER (PARTITION BY genre) THEN 'Critic Below Average'
        ELSE 'Critic Average'
    END AS critic_category,
    CASE
        WHEN user_score > AVG(user_score) OVER (PARTITION BY genre) THEN 'User Above Average'
        WHEN user_score < AVG(user_score) OVER (PARTITION BY genre) THEN 'User Below Average'
        ELSE 'User Average'
    END AS user_category
FROM video_games
WHERE critic_score <> 0 AND user_score <> 0
ORDER BY genre; 

--2.7 Score aralıklarına göre (ör: 0-50, 51-75, 76-100) toplam satışları ve ortalamaları hesapla.
SELECT
    CASE
        WHEN critic_score BETWEEN 0 AND 50 THEN '0-50'
        WHEN critic_score BETWEEN 51 AND 75 THEN '51-75'
        WHEN critic_score BETWEEN 76 AND 100 THEN '76-100'
        ELSE 'Unknown'
    END AS critic_score_range,
    SUM(global_sales) AS total_sales,
    ROUND(AVG(global_sales)) AS avg_sales
FROM video_games
WHERE critic_score <> 0
GROUP BY 1
ORDER BY 1;
--
SELECT
	CASE
		WHEN user_score BETWEEN 0 AND 3 THEN '0-3'
		WHEN user_score BETWEEN 4 AND 7 THEN '4-7'
		WHEN user_score BETWEEN 8 AND 10 THEN '8-10'
		ELSE 'Unknown'
	END AS user_score_range,
	SUM(global_sales) AS total_sales,
	ROUND(AVG(global_sales)) AS avg_sales
FROM video_games
WHERE user_score <> 0 
GROUP BY 1
ORDER BY 1;







