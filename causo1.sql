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

create table Shelf_Information_Data
(Shelf_ID int,
Description char(50),
Location_x int, 
Location_y int,
Width int,
Height int, 
Length int, 
Number_of_items int,
Shape char(50) )

	
1. Thống kê 5 mặt hàng có tổng thời gian nhìn và cầm xem lâu nhất?
select item_id, sum(looking_at_item) + sum(holding_the_item) as tong_thoi_gian_nhin_cam
from public.customer_behavior
group by item_id
order by sum(looking_at_item) + sum(holding_the_item) desc
limit 5

2. Thống kê 5 mặt hàng thường được cầm lên rồi trả lại nhiều nhất?
select  item_id, count(item_id)
from public.customer_behavior
where holding_the_item <> 0 and returning_item ='True'
group by item_id
order by count(item_id) desc
limit 5

	
3. Các nhóm khách hàng theo độ tuổi (Thiếu niên: 18 - 30; Trung niên: 31 - 60; Cao
tuổi: > 60) mua mặt hàng nào nhiều nhất?
Làm sạch, xử lý vấn đề được mua hàng
- đề bài giải thích rằng Mặt hàng được xem là “được mua” khi mặt hàng đấy được bỏ vào giỏ hàng và không được lấy ra
	nên với yêu cầu đề bài thì đầu tiên khách hàng phải hold the bag trước khi mua hàng( dù thực tế có nhiều khách
	không cần cầm giỏ hàng để đi vào trong siêu thị mua hàng)
=> điều kiện bắt buộc: holding_the_bag ='true'
TH1: chắc chắn mặt hàng được bỏ vào giỏ và không được lấy ra ( không cần phải quan tâm có cầm sản phẩm lên xem không hay có nhìn sản phẩm hay không)
=> ĐIỀU KIỆN: holding_the_bag = 'true' and picking_up_item ='true' 
	and putting_item_into_bag='true' and taking_item_out_of_bag='false'
	 and returning_item='false' and putting_item_into_bag_in_the_2nd_time in ('false',null)
	( giải thích: khách hàng bắt buộc phải nhặt sản phẩm lên ,không cần phải quan tâm có cầm sản phẩm lên xem không hay có nhìn sản phẩm hay không
	vì chỉ để chắc chắn có nhặt lên thì mới bỏ vào được giỏ. Tiếp theo đó Khách hàng sẽ bỏ sản phẩm vào giỏ và sẽ không có việc bỏ lên kệ
        rồi bỏ vào túi lần 2)
	
	select item_id, looking_at_item,holding_the_item,holding_the_bag,picking_up_item,
returning_item,putting_item_into_bag,
taking_item_out_of_bag,putting_item_into_bag_in_the_2nd_time
from public.customer_behavior
where holding_the_bag = 'true' and picking_up_item ='true'
and putting_item_into_bag='true' and taking_item_out_of_bag='false'
and returning_item='false' 
and putting_item_into_bag_in_the_2nd_time in ('false',null)

	
TH2: mặt hàng được bỏ vào giỏ -> bỏ ra khỏi giỏ -> bỏ lên kệ -> bỏ vào giỏ lần 2 
	( hành vi khách hàng có thể bỏ ra khỏi giỏ + không bỏ lên kệ rồi vẫn có thể bỏ vào giỏ tiếp được nhưng BTC giải thích đề bài 
         là bỏ vào lần 2 sau khi đã bỏ lên kệ nên mình sẽ chỉ xét trường hợp này)
=> ĐIỀU KIỆN: holding_the_bag = 'true' and picking_up_item ='true' 
	and putting_item_into_bag='true' and taking_item_out_of_bag='true'
	and returning_item='true' and putting_item_into_bag_in_the_2nd_time ='true'

code:
with cte2 as 
(select *,
 case when age between 18 and 30 then 'thieu_nien'
     when age between 31 and 60 then 'trung_nien'
	 when age > 60 then 'cao_tuoi'
end nhom_tuoi
from public.customer_behavior
where holding_the_bag = 'true' and picking_up_item ='true'
and putting_item_into_bag='true' and taking_item_out_of_bag='true'
and returning_item='true' 
and putting_item_into_bag_in_the_2nd_time ='true'),
 cte1 as
(select *, 
 case when age between 18 and 30 then 'thieu_nien'
     when age between 31 and 60 then 'trung_nien'
	 when age > 60 then 'cao_tuoi'
end nhom_tuoi
from public.customer_behavior
where holding_the_bag = 'true' and picking_up_item ='true'
and putting_item_into_bag='true' and taking_item_out_of_bag='false'
and returning_item='false' 
and putting_item_into_bag_in_the_2nd_time in ('false',null)),
cte3 as 
(select * from cte1 union all select * from cte2),
cte4 as
(select nhom_tuoi, item_id, count(item_id) as count_item
from cte3
group by nhom_tuoi,item_id),
cte5 as
(select *, rank () over (partition by nhom_tuoi order by count_item desc ) as rank_1
from cte4)
select * from cte5
where rank_1 =1






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
limit 1 

9. Top 3 quầy hàng có số sản phẩm được mua nhiều nhất: 1,7,0
	with cte2 as 
(select * from public.customer_behavior
where holding_the_bag = 'true' and picking_up_item ='true'
and putting_item_into_bag='true' and taking_item_out_of_bag='true'
and returning_item='true' 
and putting_item_into_bag_in_the_2nd_time ='true'),
 cte1 as
(select * from public.customer_behavior
where holding_the_bag = 'true' and picking_up_item ='true'
and putting_item_into_bag='true' and taking_item_out_of_bag='false'
and returning_item='false' 
and putting_item_into_bag_in_the_2nd_time in ('false',null))
, cte3 as (select * from cte1 union all select * from cte2)
select shelf_id, count(shelf_id) as count_shelf_id
from cte3
group by shelf_id
order by count(shelf_id) desc
limit 3






10. Người dùng có thói quen di chuyển từ quầy 7 sang quầy 0 là nhiều nhất
with cte2 as
(select shelf_id,person_id, shelf_id - lead(shelf_id) over (partition by person_id order by timestamp) as next_shelf_id
from public.customer_behavior
order by person_id asc),
cte3 as
(select shelf_id,person_id  from cte2
where next_shelf_id <> 0 or next_shelf_id is null),
cte4 as 
(select shelf_id,person_id, 
lead(shelf_id) over (partition by person_id) as next_shelf_id_1
from cte3),
cte5 as 
(select person_id, shelf_id, next_shelf_id_1 from cte4
where next_shelf_id_1 is not null),
cte6 as
(select person_id, 
 cast( cast(shelf_id as varchar)||cast(next_shelf_id_1 as varchar) as int) as next_shelf_id_1_1
from cte5)
select next_shelf_id_1_1, count(person_id)
from cte6 
group by next_shelf_id_1_1
order by count(person_id) desc


