# README

- bundle
- rails s
  
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
        "fields": {
          "price": ".price-box__price",
          "rating_count": ".ratingCount",
          "rating_value": ".ratingValue",
          "beer": ".beer"
        }
      }' \
