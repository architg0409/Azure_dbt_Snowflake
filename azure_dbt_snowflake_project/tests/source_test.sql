{{ config(severity='warn')}}

select 1
from {{ source('staging','bookings')}}
where BOOKING_AMOUNT < 0