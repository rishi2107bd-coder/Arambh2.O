-- Arambh 2.0 schema. Run once in Supabase > SQL Editor.
create table public.profiles(id uuid primary key references auth.users on delete cascade, role text not null default 'customer' check(role in('customer','admin')));
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into profiles(id) values(new.id); return new; end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
-- Admin = role 'admin' in DB AND a session verified with MFA (aal2). Email alone never grants access.
create function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
 select coalesce((auth.jwt()->>'aal')='aal2',false) and exists(select 1 from profiles where id=auth.uid() and role='admin') $$;

create table public.products(
 id bigint generated always as identity primary key,
 name text not null check(char_length(name) between 1 and 60),
 cat text not null check(cat in('Sensors','Motors & drivers','Controllers','Robot kits','Batteries & power','Tools & parts')),
 cond text not null check(cond in('New','Used – like new','Used – good')),
 price integer not null check(price between 1 and 1000000),
 stock integer not null default 0 check(stock between 0 and 100000),
 status text not null default 'available' check(status in('available','soldout','hidden')),
 description text not null default '' check(char_length(description)<=140),
 image_url text, seller text not null default 'Arambh 2.0', official boolean not null default true,
 content_hash text check(content_hash ~ '^[0-9a-f]{64}$'),
 created_at timestamptz not null default now());
create table public.settings(id int primary key check(id=1),
 hero_title text not null check(char_length(hero_title)<=120), hero_text text not null check(char_length(hero_text)<=400),
 ig text not null check(ig ~ '^[A-Za-z0-9._]{1,30}$'), markup integer not null check(markup between 0 and 10000));

alter table profiles enable row level security; alter table products enable row level security; alter table settings enable row level security;
create policy "own profile" on profiles for select using(id=auth.uid());       -- no write policy: nobody can self-promote
create policy "public read" on products for select using(status<>'hidden' or is_admin());
create policy "admin insert" on products for insert with check(is_admin());
create policy "admin update" on products for update using(is_admin()) with check(is_admin());
create policy "admin delete" on products for delete using(is_admin());
create policy "public read" on settings for select using(true);
create policy "admin update" on settings for update using(is_admin()) with check(is_admin());

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('product-images','product-images',true,2097152,array['image/jpeg','image/png','image/webp']) on conflict do nothing;
create policy "img read" on storage.objects for select using(bucket_id='product-images');
create policy "img insert" on storage.objects for insert with check(bucket_id='product-images' and is_admin());
create policy "img update" on storage.objects for update using(bucket_id='product-images' and is_admin());
create policy "img delete" on storage.objects for delete using(bucket_id='product-images' and is_admin());

alter publication supabase_realtime add table products, settings;

insert into settings values(1,'Every robot starts somewhere.','Buy sensors, motors, controllers and kits directly from us. No middleman: we own every product we sell, and we confirm your delivery address with you on Instagram. Have parts you no longer use? List them and sell to other makers.','rishi2107bd',30);
insert into products(name,cat,cond,price,stock,description) values
('Ultrasonic sensor HC-SR04','Sensors','New',100,10,'Distance sensing up to 4 m.'),
('IR obstacle sensor (5 pack)','Sensors','New',150,10,'Line following and obstacle detection.'),
('MPU6050 gyro + accelerometer','Sensors','New',210,10,'6-axis motion sensor, I2C.'),
('N20 geared motor 300 RPM','Motors & drivers','New',260,10,'Compact motor for small bots.'),
('L298N motor driver','Motors & drivers','Used – like new',120,10,'Works with two DC motors.'),
('SG90 micro servo (4 pack)','Motors & drivers','New',380,10,'Light 9 g servos.'),
('Arduino Uno R3 clone','Controllers','New',450,10,'ATmega328P with USB cable.'),
('ESP32 DevKit','Controllers','New',520,10,'Wi-Fi and Bluetooth built in.'),
('Raspberry Pi 4 (4 GB)','Controllers','Used – good',3800,10,'Includes case and power supply.'),
('Line follower robot kit','Robot kits','New',1299,10,'Build and code your first robot.'),
('4WD smart car chassis','Robot kits','Used – like new',780,10,'Assembled once, all screws included.'),
('2S LiPo 1500 mAh','Batteries & power','New',640,10,'7.4 V with XT60 connector.'),
('Soldering iron 60 W','Tools & parts','Used – good',350,10,'Adjustable temperature.');
