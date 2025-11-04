select * from customer

-- Q1. Berapa total pendapatan yang dihasilkan oleh pelanggan laki-laki vs. pelanggan perempuan?
select gender, SUM (purchase_amount_usd) as revenue
from customer
group by gender

-- Q2. Pelanggan mana yang menggunakan diskon tetapi tetap membelanjakan lebih dari rata-rata jumlah pembelian?
select customer_id, purchase_amount_usd
from customer
where discount_applied = 'Yes' and purchase_amount_usd > (select AVG(purchase_amount_usd) from customer)

-- Q3. Apa saja 5 produk teratas dengan rating ulasan rata-rata tertinggi?
select item_purchased, ROUND(AVG(review_rating::numeric), 1) as "Rata - Rata ulasan produk"
from customer
group by item_purchased
order by AVG(review_rating) desc
limit 5

-- Q4. Bandingkan rata-rata jumlah pembelian antara pengiriman Standard dan Express.
select shipping_type, ROUND(AVG(purchase_amount_usd), 2) as "Rata - rata pembelian berdasarkan tipe pengiriman"
from customer
where shipping_type in ('Standard', 'Express')
group by shipping_type

-- Q5. Apakah pelanggan yang berlangganan (subscribed) membelanjakan lebih banyak? Bandingkan rata-rata pengeluaran dan total pendapatan antara pelanggan yang berlangganan dan yang tidak.
select subscription_status, COUNT(customer_id) as total_customer, 
ROUND(AVG(purchase_amount_usd::numeric), 2) as "Rata - rata pembelian",
SUM(purchase_amount_usd) as total_pendapatan
from customer
group by subscription_status
order by total_pendapatan, "Rata - rata pembelian"

-- Q6. Manakah 5 produk yang memiliki persentase pembelian dengan diskon tertinggi?
select item_purchased, ROUND(100*SUM(CASE WHEN discount_applied='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5

-- Q7. Segmentasikan pelanggan menjadi Baru (New), Kembali (Returning), dan Loyal berdasarkan total jumlah pembelian sebelumnya, lalu tampilkan jumlah masing-masing segmen.
with customer_type as (
select customer_id, previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 3 AND 8 THEN 'Returning'
	ELSE 'Loyal'
	END as customer_segment
from customer
)
select customer_segment, count(*) as "Jumlah Customer"
from customer_type
group by customer_segment
-- Q8. Apa saja 3 produk yang paling banyak dibeli dalam setiap kategori?
with item_counts as (
select category, item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id)DESC) as peringkat_item
from customer
group by category, item_purchased
)

select peringkat_item, category, item_purchased, total_orders
from item_counts
where peringkat_item <= 3

-- Q9. Apakah pelanggan yang merupakan pembeli ulang (lebih dari 3 kali pembelian sebelumnya) juga cenderung berlangganan?
select subscription_status, COUNT(customer_id) as repeat_buyers
from customer
where previous_purchases > 3
group by subscription_status

-- Q10. Berapa kontribusi pendapatan dari setiap kelompok umur?
select age_group, SUM(purchase_amount_usd) as total_pendapatan
from customer
group by age_group
order by total_pendapatan desc