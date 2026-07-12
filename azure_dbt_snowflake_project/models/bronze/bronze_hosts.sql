{# {% set incremental_flag = 1 %}
{% set incremental_col = 'CREATED_AT' %}

select * from {{ source('staging','hosts') }}

{% if incremental_flag == 1 %}
where {{ incremental_col }} > (select coalesce(max({{ incremental_col }}),'1900-01-01') from {{ this }})
{% endif %} #}

{{ config(materialized='incremental') }}

select * from {{ source("staging","hosts") }}

{% if is_incremental() %}
where CREATED_AT > (select coalesce(max(CREATED_AT),'1900-01-01') from {{ this }})
{% endif %}