ES='http://localhost:9200'
ESIDX='hai-idx'
CURL="curl --silent -H Content-Type:application/json"

function createHaiIdx {
    local es_idx="hai-idx"
    local settings='
    {
    "settings" : {
        "index":{
        "analysis":{
            "analyzer":{
            "korean":{
                "type":"custom",
                "tokenizer":"seunjeon_default_tokenizer"
            }
            },
            "tokenizer": {
            "seunjeon_default_tokenizer": {
                "type": "seunjeon_tokenizer",
                "index_eojeol": false,
                "user_words": ["낄끼+빠빠,-100", "c\\+\\+", "어그로", "버카충", "abc마트"]
            }
            }
        }
        }
    },
    "mappings": {
        "doc": {
        "properties": {
            "utterance": { "type": "text", "analyzer": "korean" }
        }
        }
    }
    }'

    echo "${ES}/${es_idx}?pretty"
    curl -XDELETE "${ES}/${es_idx}?pretty"
    sleep 1

    $CURL -XPUT "${ES}/${es_idx}/?pretty" -d "$settings"

    sleep 3

    $CURL -XGET 'localhost:9200/_cat/indices?v&pretty'

    # curl -XDELETE http://localhost:9200/hai-idx?pretty
    # curl -XGET 'localhost:9200/_cat/indices?v&pretty'
}

function testHaiIdx {
    local es_idx="hai-idx"

    #$CURL -XPOST "${ES}/${ESIDX}/doc/3000?pretty" -d '{ "indx" : "1", "intent" : "ECS_SNC_PI_ERP_INQUIRY_TEAM_BUDGET",  "utterance" : "Biz.컨설팅팀 통제예산 알려줘" }' | jq
    #$CURL -XGET "${ES}/${ESIDX}/doc/3000" | jq

    #curl -XDELETE "${ES}/${ESIDX}?pretty"
    sleep 1

    $CURL -XGET 'localhost:9200/_cat/indices?v&pretty'


    #$CURL -XGET "${ES}/${ESIDX}/_analyze?pretty" -d "{\"analyzer\": \"korean\", \"text\": \"Biz.컨설팅팀 통제예산 알려줘\"}"
    $CURL -XGET "${ES}/${ESIDX}/_analyze" -d "{\"analyzer\": \"korean\", \"text\": \"Biz.컨설팅팀 통제예산 알려줘\"}"
    
    $CURL -XGET "${ES}/${ESIDX}/doc/2322" | jq
    $CURL -XGET "${ES}/${ESIDX}/doc/3000" | jq
    #$CURL -XGET "${ES}/${ESIDX}/_search" -d '{"query":{"match": {"intent": "ECS_SNC_PI_ERP_INQUIRY_TEAM_BUDGET"}}}}}' | jq
    #$CURL -XGET "${ES}/${ESIDX}/_search" -d '{"query":{"match": {"utterance": {"query": "통제예산"}}}}}}' | jq
    #$CURL -XGET "${ES}/${ESIDX}/_search" -d '{"query":{"match": {"utterance": {"query": "통제 예산"}}}}}}' | jq
    #$CURL -XGET "${ES}/${ESIDX}/_search" -d '{"query":{"match": {"utterance": {"query": "통제 예산", "operator": "and"}}}}}}' | jq
    $CURL -XGET "${ES}/${ESIDX}/_search" -d '{"query":{"match": {"utterance": {"query": "통제예산 알려", "operator": "and"}}}}}}' | jq
    #$CURL -XGET "${ES}/${ESIDX}/_search" -d '{"query":{"match": {"utterance": {"query": "텅제 예산", "operator": "and"}}}}}}' | jq
    $CURL -XGET "${ES}/${ESIDX}/_search" -d '{"query":{"match": {"utterance": {"query": "텅제 예산"}}}}}}' | jq
}
    createHaiIdx
    #testHaiIdx

