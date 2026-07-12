{% set configs = [
    {
        "table": "AIRBNB.GOLD.OBT",
        "columns": "GOLD_obt.BOOKING_ID,GOLD_obt.HOST_ID,GOLD_obt.LISTING_ID,GOLD_obt.TOTAL_BOOKING_AMOUNT,GOLD_obt.SERVICE_FEE,GOLD_obt.CLEANING_FEE,GOLD_obt.ACCOMMODATES,GOLD_obt.BEDROOMS,GOLD_obt.BATHROOMS,GOLD_obt.PRICE_PER_NIGHT,GOLD_obt.RESPONSE_RATE",
        "alias": "GOLD_obt"
    },
    {
        "table": "AIRBNB.GOLD.DIM_LISTINGS",
        "columns": "",
        "alias": "GOLD_listings",
        "join_condition": "GOLD_obt.listing_id = GOLD_listings.listing_id"
    },
    {
        "table": "AIRBNB.GOLD.DIM_HOSTS",
        "columns": "",
        "alias": "GOLD_hosts",
        "join_condition": "GOLD_hosts.host_id = GOLD_obt.host_id"
    }
]%}

SELECT
    {{ configs[0]['columns'] }}
FROM
    {% for config in configs %}
        {% if loop.first  %}
            {{ config['table'] }} AS {{ config['alias'] }}
        {% else %}
            LEFT JOIN {{ config['table'] }} AS {{ config['alias'] }} 
            ON {{ config['join_condition'] }}
        {% endif %}
    {% endfor %}