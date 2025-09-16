# [TR]
# 🎮 Video Games Sales Analysis

Bu proje, video oyunları satış verilerini kullanarak **trend analizi**, **performans değerlendirmesi** ve **puan bazlı kategorize etme** işlemlerini yapmayı amaçlamaktadır. PostgreSQL kullanılarak **veri temizleme**, **window function** ve **CTE (Common Table Expression)** yöntemleri ile kapsamlı analizler gerçekleştirilmiştir.

---

## 📂 Veri Kaynağı

| Sütun | Açıklama |
|-------|----------|
| `name` | Oyun adı |
| `developer` | Geliştirici |
| `publisher` | Yayıncı |
| `genre` | Tür |
| `platform` | Platform |
| `critic_score` | Eleştirmen puanı |
| `user_score` | Kullanıcı puanı |
| `na_sales`, `eu_sales`, `jp_sales`, `other_sales` | Bölgesel satışlar |
| `global_sales` | Toplam satış |
| `year_of_release` | Yayınlanma yılı |
ve daha fazlası
- Boş değerler `COALESCE` ile doldurulmuştur.  

---

## 🛠️ Kullanılan Teknolojiler

- **PostgreSQL**  
- SQL sorguları: `GROUP BY`, `ORDER BY`, `CASE`, `WINDOW FUNCTIONS` (ROW_NUMBER, RANK, AVG, SUM)  
- Veri temizleme: `COALESCE`, `NULLIF`  

---

## 🔍 Yapılan Analizler

1. En çok satan oyunlar ve yayıncılar  
2. Yıllara göre satış trendi  
3. Platform ve genre bazlı satış analizi  
4. Puan ve satış ilişkisi  
5. Bölgesel satış dağılımı  
6. Her genre’de oyunları Kuzey Amerika satışına göre sıralama  
7. Yıllara göre en çok satan yayıncı ve sıralamaları (RANK)  
8. Her oyunun toplam satışının, kendi genre’sindeki payı (%)  
9. Publisher bazlı ortalama satış ve Above/Below Average kategorisi  
10. Her oyunun toplam global satışının, kendi yılındaki maksimum satışa oranı (%)  
11. Publisher’ın en çok hangi platformda satış yaptığı  
12. Yıllara göre en başarılı ve en başarısız yayıncılar  
13. Genre bazlı ortalama critic_score ve user_score  
14. Critic ve User skorlarına göre Above/Below Average kategorize etme  
15. Score aralıklarına göre toplam satış ve ortalama satış analizi  

---

## 📝 Örnek Sorgular

**1️⃣ Genre’e göre Above/Below Average kategorisi**

sql
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

--- 

🔗 Proje Kullanımı
PostgreSQL veritabanına video_games_sales tablosunu yükleyin.
video_games view’ını oluşturun.
Hazır SQL sorgularını çalıştırarak analizleri elde edin.

---

📌 Notlar
Null değerler ve boş stringler COALESCE ile 0 veya Unknown olarak değiştirilmiştir.
Window function ve CTE kullanımı ile satır bazlı hesaplamalar ve sıralamalar yapılmıştır. 

# [EN]
# 🎮 Video Games Sales Analysis

This project analyzes **video game sales data** to provide **trend insights**, **performance evaluation**, and **score-based categorization**.  
PostgreSQL is used with **data cleaning**, **window functions**, and **CTEs (Common Table Expressions)** to perform comprehensive analyses.

---

## 📂 Data Source

| Column | Description |
|--------|-------------|
| `name` | Game title |
| `developer` | Developer |
| `publisher` | Publisher |
| `genre` | Genre |
| `platform` | Platform |
| `critic_score` | Critic score |
| `user_score` | User score |
| `na_sales`, `eu_sales`, `jp_sales`, `other_sales` | Regional sales |
| `global_sales` | Total sales |
| `year_of_release` | Release year |

> **Note:** Null or empty values are replaced using **`COALESCE`**.

---

## 🛠️ Technologies Used

- **PostgreSQL**  
- SQL queries: `GROUP BY`, `ORDER BY`, `CASE`, **WINDOW FUNCTIONS** (`ROW_NUMBER`, `RANK`, `AVG`, `SUM`)  
- Data cleaning: `COALESCE`, `NULLIF`  

---

## 🔍 Analyses Performed

- 🏆 Top-selling games and publishers  
- 📈 Yearly sales trends  
- 🎮 Platform and genre-based sales analysis  
- 📊 Relationship between scores and sales  
- 🌍 Regional sales distribution  
- 🥇 Ranking games within each genre by North America sales  
- 📅 Top publishers per year with RANK  
- 📊 Each game’s share (%) of total sales within its genre  
- 💹 Publisher-level average sales and Above/Below Average categorization  
- 🌟 Game’s total global sales as a percentage of yearly maximum  
- 🏅 Publisher’s top-selling platform  
- 📉 Most and least successful publishers by year  
- 🎯 Average critic_score and user_score by genre  
- ⚖️ Categorizing games as Above/Below Average by critic and user scores  
- 📊 Total and average sales by score ranges  

---

🔗 How to Use
Load the video_games_sales table into your PostgreSQL database.
Create the video_games view.
Run the prepared SQL queries to get the analyses.

---

📌 Notes
Null values and empty strings are replaced with 0 or Unknown using COALESCE.
Window functions and CTEs are used for row-wise calculations and ranking.
