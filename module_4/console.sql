/*Задание 4.1
  База данных содержит список аэропортов практически всех крупных городов России.
  В большинстве городов есть только один аэропорт. Исключение составляет:
 */

select a.city,
       count(a.airport_name) AS count_airports --кол-во аэропортов
from dst_project.airports a
group by 1 --группировка по городам
having count(a.airport_name) > 1;

/*Задание 4.2
Вопрос 1. Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах.
  Сколько всего статусов для рейсов определено в таблице?*/

select count(distinct f.status)
from dst_project.flights f;

/*Вопрос 2. Какое количество самолетов находятся в воздухе на момент среза в базе
  (статус рейса «самолёт уже вылетел и находится в воздухе»).*/

select count(*)
from dst_project.flights f
where f.status = 'Departed';

/*Вопрос 3. Места определяют схему салона каждой модели.
  Сколько мест имеет самолет модели 773 (Boeing 777-300)?*/

select count(s.seat_no)
from dst_project.aircrafts a
         join dst_project.seats s on a.aircraft_code = s.aircraft_code
where a.aircraft_code = '773'
  and a.model = 'Boeing 777-300';

/*Вопрос 4. Сколько состоявшихся (фактических) рейсов было совершено
  между 1 апреля 2017 года и 1 сентября 2017 года?*/

select count(f.flight_id)
from dst_project.flights f
where ((f.actual_departure between '2017-04-01' and '2017-09-01')
    or (f.actual_arrival between '2017-04-01' and '2017-09-01'))
  and f.status = 'Arrived';

/*Задание 4.3
  Вопрос 1. Сколько всего рейсов было отменено по данным базы?*/

select count(*) --кол-во строк
from dst_project.flights f
where f.status = 'Cancelled';

/*Вопрос 2. Сколько самолетов моделей типа
  Boeing, Sukhoi Superjet, Airbus находится в базе авиаперевозок?*/

with Boeing_count as
         (select 'Boeing' AS type_aircraft,
                 count(*)
          from dst_project.aircrafts a
          where a.model like 'Boeing%'),
     Sukhoi_count as
         (select 'Sukhoi' AS type_aircraft,
                 count(*)
          from dst_project.aircrafts a
          where a.model like 'Sukh%'),
     Airbus as
         (select 'Airbus' AS type_aircraft,
                 count(*)
          from dst_project.aircrafts a
          where a.model like 'Airbus%')
select *
from Boeing_count
union
select *
from Sukhoi_count
union
select *
from Airbus;

/*Вопрос 3. В какой части (частях) света находится больше аэропортов?*/

select split_part(a.timezone, '/', 1) AS region,
       count(a.airport_name)             aiport_count
from dst_project.airports a
group by 1;

/*Вопрос 4. У какого рейса была самая большая задержка прибытия за все время сбора данных?
  Введите id рейса (flight_id).*/

select f.flight_id,
       max(f.actual_arrival - f.scheduled_arrival)
from dst_project.flights f
where not f.actual_arrival is null
group by 1
order by 2 desc
limit 1;

/*Задание 4.4
Вопрос 1. Когда был запланирован самый первый вылет, сохраненный в базе данных?*/

select min(date_trunc('day', f.scheduled_departure)) first_shedul
from dst_project.flights f;

/*Вопрос 2. Сколько минут составляет запланированное время полета в самом длительном рейсе?*/

select max(
                   date_part('hour', f.scheduled_arrival - f.scheduled_departure) * 60 + --получаем из часов минуты и складываем с минутами
                   date_part('min', f.scheduled_arrival - f.scheduled_departure)) max_duration
from dst_project.flights f;

/*Вопрос 3. Между какими аэропортами пролегает самый длительный по времени запланированный рейс?*/

select a.departure_airport,
       a.arrival_airport
from (select f.departure_airport,
             f.arrival_airport,
             date_part('hour', f.scheduled_arrival - f.scheduled_departure) * 60 +
             date_part('min', f.scheduled_arrival - f.scheduled_departure) AS duration
      from dst_project.flights f
      order by 3 desc) a
limit 1;

/*Вопрос 4. Сколько составляет средняя дальность полета среди всех самолетов в минутах? Секунды округляются в меньшую сторону (отбрасываются до минут).*/

select avg(
                   date_part('hour', f.scheduled_arrival - f.scheduled_departure) * 60 + --получаем из часов минуты и складываем с минутами
                   date_part('min', f.scheduled_arrival - f.scheduled_departure))::int
from dst_project.flights f;

/*Задание 4.5
  Вопрос 1. Мест какого класса у SU9 больше всего?*/

select s.fare_conditions,
       count(s.seat_no) count_seats
from dst_project.seats s
where s.aircraft_code = 'SU9'
group by 1;

/*Вопрос 2. Какую самую минимальную стоимость составило бронирование за всю историю?*/

select min(total_amount) AS min_booking
from dst_project.bookings;

/*Вопрос 3. Какой номер места был у пассажира с id = 4313 788533?*/

select*
from dst_project.seats;

select bp.seat_no
from (select t.ticket_no,
             t.passenger_id
      from dst_project.tickets t
      where passenger_id = '4313 788533') pass--таблица с пассажиром с нужным id
         left join dst_project.boarding_passes bp on pass.ticket_no = bp.ticket_no;
--соединяем с таблицей посадочных талонов

/*Задание 5.1
  Вопрос 1. Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?*/

select count(f.flight_id)
from dst_project.flights f
where f.arrival_airport = 'AAQ' --уникальный индефикатор аэропорта Анапы
  and f.status = 'Arrived'
  and extract('year' from f.actual_arrival) = 2017;

/*Вопрос 2. Сколько рейсов из Анапы вылетело зимой 2017 года?*/
select count(f.flight_id)
from dst_project.flights f
where f.arrival_airport = 'AAQ'
  and extract('year' from f.actual_departure) = 2017
  and extract('month' from f.actual_departure) in (12, 1, 2);

/*Вопрос 3. Посчитайте количество отмененных рейсов из Анапы за все время.*/

select count(*)
from dst_project.flights f
where f.departure_airport = 'AAQ'
  and f.status = 'Cancelled';

/*Вопрос 4. Сколько рейсов из Анапы не летают в Москву?*/

select count(f.flight_id)
from dst_project.flights f
         left join dst_project.airports a on f.arrival_airport = a.airport_code
where f.departure_airport = 'AAQ'
  and not a.city = 'Moscow';

/*Вопрос 5. Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?*/

select count(distinct s.seat_no),
       a.model
from dst_project.flights f
         left join dst_project.seats s on f.aircraft_code = s.aircraft_code
         left join dst_project.aircrafts a on f.aircraft_code = a.aircraft_code
where f.departure_airport = 'AAQ'
group by 2;

/*final*/
with A_flight AS -- таблица полетов с аэпорта анапы
         (SELECT f.flight_id,
                 f.departure_airport,
                 f.arrival_airport,
                 f.aircraft_code,
                 f.actual_departure,
                 f.actual_arrival,
                 round((date_part('minute', actual_arrival - actual_departure) / 60.0 +
                        date_part('hour', actual_arrival - actual_departure))::numeric,
                       2) as duration, --время полета в часах
                 ac.model
          FROM dst_project.flights f
                   left join dst_project.aircrafts ac on f.aircraft_code = ac.aircraft_code
          WHERE departure_airport = 'AAQ'
            AND (date_trunc('month', scheduled_departure) in ('2017-01-01', '2017-02-01', '2017-12-01'))
            AND status not in ('Cancelled')),
     earn AS --таблица выручки с рейса
         (select tf.flight_id,
                 sum(amount) earn --подсчет выручки с рейса
          from dst_project.ticket_flights tf
          group by 1),
     fuel_consumption AS --таблица потребления топлива
         (select 'Boeing 737-300' as model,
                 2400             as hour_consumption, --средне часовое потребление топлива взято с викепедии
                 130             as max_bording       --Задания 5.1.5
          union all
          select 'Sukhoi Superjet-100' as model,
                 1700                  as hour_consumption, --средне часовое потребление топлива
                 97                  as max_bording),--Задание 5.1.5
     curr_bording AS--таблица с подсчетом загруженности самолета
         (SELECT f.flight_id,
                 count(tf.ticket_no) cur_pass
          FROM dst_project.flights f
                   left join dst_project.ticket_flights tf on f.flight_id = tf.flight_id
          WHERE f.departure_airport = 'AAQ'
            AND (date_trunc('month', f.scheduled_departure) in ('2017-01-01', '2017-02-01', '2017-12-01'))
            AND f.status not in ('Cancelled')
          group by 1)
select A.*,
       e.earn,
       fc.hour_consumption,
       fc.max_bording,
       cb.cur_pass,
       round(((cb.cur_pass / 1.0) / fc.max_bording), 2)  perc_bording,
       e.earn - (A.duration / 1.0) * fc.hour_consumption * 40 profit /*40р средня стоймость на кг*/


from A_flight As A
         left join earn e on e.flight_id = A.flight_id
         left join fuel_consumption fc on fc.model = A.model
         left join curr_bording cb on cb.flight_id = A.flight_id
where not A.arrival_airport = 'NOZ' --т.к не данных по выручке, удаляем
order by 7 desc
