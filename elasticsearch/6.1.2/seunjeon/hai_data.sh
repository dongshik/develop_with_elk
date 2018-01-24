ES='http://localhost:9200'
ESIDX='seunjeon-idx'
CURL="curl --silent -H Content-Type:application/json"
CURL2="curl"

#$CURL -XPOST "${ES}/${es_idx}/doc/2?pretty" -d '{ "field1" : "삼성전자" }'
# $CURL -XGET "${ES}/${es_idx}/doc/1" 

function assertEquals() {
    local actual=$1
    local expect=$2

    if [ "$expect" == "$actual" ]; then
        return 0
    else
        echo "fail: expect: $expect, but actual: $actual"
        command -v jq > /dev/null
        if [ $? -eq 0 ]; then
            echo "expect:"
            echo $expect | jq
            echo "actual:"
            echo $actual | jq
        fi
        return 1
    fi
}

function test_analysis() {
    local input=$1
    local expect=$2

    RESULT=$($CURL -XGET "${ES}/${es_idx}/_analyze" -d "{
        \"analyzer\": \"korean\", 
        \"text\": \"$input\"
    }") 
    assertEquals $RESULT "$expect"
    if [ "$?" -eq 0 ]; then
        echo "success $input"
    fi
    
}

function analysis() {
    local input=$1

    RESULT=$($CURL -XGET "${ES}/${es_idx}/_analyze?pretty" -d "{
        \"analyzer\": \"korean\", 
        \"text\": \"$input\"
    }") 

    echo "success $RESULT"

    
}

function testSeunjeon1 {
    local es_idx="seunjeon-idx"
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
            "field1": { "type": "text", "analyzer": "korean" }
        }
        }
    }
    }'

    curl -XDELETE "${ES}/${es_idx}?pretty"
    sleep 1

    $CURL -XPUT "${ES}/${es_idx}/?pretty" -d "$settings"

    sleep 1

    #test_analysis "삼성전자" '{"tokens":[{"token":"삼성/N","start_offset":0,"end_offset":2,"type":"N","position":0},{"token":"전자/N","start_offset":2,"end_offset":4,"type":"N","position":1}]}'

    #test_analysis "빨라짐" '{"tokens":[{"token":"빠르/V","start_offset":0,"end_offset":2,"type":"V","position":0},{"token":"지/V","start_offset":2,"end_offset":3,"type":"V","position":1}]}'

    #test_analysis "슬픈" '{"tokens":[{"token":"슬프/V","start_offset":0,"end_offset":2,"type":"V","position":0}]}'

    #test_analysis "새로운사전생성" '{"tokens":[{"token":"새롭/V","start_offset":0,"end_offset":2,"type":"V","position":0},{"token":"사전/N","start_offset":3,"end_offset":5,"type":"N","position":1},{"token":"생성/N","start_offset":5,"end_offset":7,"type":"N","position":2}]}'

    #test_analysis "낄끼빠빠 c++" '{"tokens":[{"token":"낄끼/N","start_offset":0,"end_offset":2,"type":"N","position":0},{"token":"빠빠/N","start_offset":2,"end_offset":4,"type":"N","position":1},{"token":"c++/N","start_offset":5,"end_offset":8,"type":"N","position":2}]}'

    #analysis "아버지가 방에 들어간다."
    #analysis "새로운사전생성"
    #analysis "점쟁이 문어 파울, 스페인의 FIFA 월드컵 우승 예언"

    #$CURL -XGET "${ES}/${es_idx}/_analyze?analyzer=korean\&pretty=true" -d "아버지가 방에 들어간다"

    IN_STR="아버지가 방에 들어간다"
    $CURL -XGET "${ES}/${es_idx}/_analyze?pretty" -d "{\"analyzer\": \"korean\", \"text\": \"$IN_STR\"}"
    
    #$CURL -XPOST "${ES}/${es_idx}/doc/1?pretty" -d ' { "field1" : "삼성전자" }' | jq
    #$CURL -XGET "${ES}/${es_idx}/doc/1" | jq

    #$CURL -XPOST "${ES}/${es_idx}/doc/2?pretty" -d ' { "field1" : ["삼성 전자", "엘지 전자"] }' | jq
    #$CURL -XGET "${ES}/${es_idx}/doc/2" | jq

    $CURL -XPOST "${ES}/${es_idx}/doc/1?pretty" -d ' { "field1" : "아버지가 방에 들어간다." }' | jq
    #$CURL -XGET "${ES}/${es_idx}/doc/1" | jq

    $CURL -XPOST "${ES}/${es_idx}/doc/2?pretty" -d ' { "field1" : "아버지께서 집에 들어간다." }' | jq
    #$CURL -XGET "${ES}/${es_idx}/doc/2" | jq

    sleep 3

    $CURL -XGET 'localhost:9200/_cat/indices?v&pretty'

    #$CURL -XGET "${ES}/${es_idx}/_search" -d '{"query":{"match": {"field1": "아버지 집"}}}}' | jq

    echo "query : 집 and 들어가다"
    $CURL -XGET "${ES}/${es_idx}/_search" -d '{"query":{"match": {"field1": {"query": "집 들어가다", "operator": "and"}}}}}}' | jq

    echo "query : 아버지 or 방"
    $CURL -XGET "${ES}/${es_idx}/_search" -d '{"query":{"match": {"field1": {"query": "아버지 방"}}}}}}' | jq

    echo "query : 아버지 or 집"
    $CURL -XGET "${ES}/${es_idx}/_search" -d '{"query":{"match": {"field1": {"query": "아버지 집"}}}}}}' | jq

    echo "query : 아버지 and 방"
    $CURL -XGET "${ES}/${es_idx}/_search" -d '{"query":{"match": {"field1": {"query": "아버지 방", "operator": "and"}}}}}}' | jq
}

testSeunjeon1