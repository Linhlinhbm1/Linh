CREATE TABLE Customer_Behavior (
    Shelf_ID INT,
    Person_ID INT,
    Timestamp int,
    Age INT,
    Gender varCHAR(25),
    Height DECIMAL(5,2),
    Weight DECIMAL(5,2),
    Married_status varCHAR(25) ,
    Moving_speed DECIMAL(5,2),
    Item_ID INT,
    Looking_at_item int,
    Holding_the_item int,
    Holding_the_bag BOOLEAN,
    Picking_up_item BOOLEAN,
    Returning_item BOOLEAN,
	Putting_item_into_bag BOOLEAN, 
    Taking_item_out_of_bag BOOLEAN,
    Putting_item_into_bag_in_the_2nd_time BOOLEAN );

1. Thống kê 5 mặt hàng có tổng thời gian nhìn và cầm xem lâu nhất?
- 5 mặt hàng có tổng thời gian nhìn lâu nhất
  select item_id, 
sum(looking_at_item) as thoi_gian_nhin
from public.customer_behavior
group by item_id
order by sum(looking_at_item) desc
limit 5
- 5 mặt hàng có tổng thời gian cầm lâu nhất
select item_id,  
sum(holding_the_item) as thoi_gian_cam
from public.customer_behavior
group by item_id
order by sum(holding_the_item) desc
limit 5
2. Thống kê 5 mặt hàng thường được cầm lên rồi trả lại nhiều nhất?
select  item_id, count(item_id)
from public.customer_behavior
where holding_the_item <> 0 and returning_item ='True'
group by item_id
order by count(item_id) desc
limit 5
3. 



5. Trong 3 nhóm tuổi sau: Thiếu niên (18 - 30), Trung niên (31 - 60), Cao tuổi: (> 60), nhóm tuổi nào có số người đi siêu thị nhiều nhất?
with cte1 as 
(select age,
case when age between 18 and 30 then 'thieu_nien'
     when age between 31 and 60 then 'trung_nien'
	 when age > 60 then 'cao_tuoi'
end nhom_tuoi
from customer_behavior)
select nhom_tuoi, count(nhom_tuoi) from cte1
group by nhom_tuoi
order by nhom_tuoi desc 

