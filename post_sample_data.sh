#!/bin/bash

set -euo pipefail

APPLICATION_HOST="http://localhost"
APPLICATION_PORT=8082

DEST="${APPLICATION_HOST}:${APPLICATION_PORT}"

ID01=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Fuel car\"                                                                                               }" ${DEST}/todos | jq ".id")
ID02=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Buy milk\",                          \"description\": \"2 Litres\",              \"depends_on\": ${ID01} }" ${DEST}/todos | jq ".id")
ID03=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Buy eggs\",                          \"description\": \"Pack of 10\",            \"depends_on\": ${ID01} }" ${DEST}/todos | jq ".id")
ID04=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Buy flour\",                         \"description\": \"2x 1kg packages\",       \"depends_on\": ${ID01} }" ${DEST}/todos | jq ".id")
ID05=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Buy potatoes\",                                                                  \"depends_on\": ${ID04} }" ${DEST}/todos | jq ".id")
ID07=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Buy toilet-paper\",                  \"description\": \"2 packs\",               \"depends_on\": ${ID04} }" ${DEST}/todos | jq ".id")
ID08=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Buy lunch\",                         \"description\": \"Baguette\",              \"depends_on\": ${ID04} }" ${DEST}/todos | jq ".id")
ID09=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Reply to client emails\",            \"description\": \"Start daily\"                                    }" ${DEST}/todos | jq ".id")
ID10=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Schedule weekly team meeting\",                                                  \"depends_on\": ${ID09} }" ${DEST}/todos | jq ".id")
ID11=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Prepare weekly sales report\",       \"description\": \"Due on Fridays\",        \"depends_on\": ${ID09} }" ${DEST}/todos | jq ".id")
ID12=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Review and publish sales report\",                                               \"depends_on\": ${ID11} }" ${DEST}/todos | jq ".id")
ID13=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Review and update team KPIs\",                                                   \"depends_on\": ${ID10} }" ${DEST}/todos | jq ".id")
ID14=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Attend team meeting\",                                                           \"depends_on\": ${ID10} }" ${DEST}/todos | jq ".id")
ID15=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Review monthly financial reports\",  \"description\": \"Check revenue/expense\"                          }" ${DEST}/todos | jq ".id")
ID16=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Update budget forecast\",                                                        \"depends_on\": ${ID15} }" ${DEST}/todos | jq ".id")
ID17=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Report budget to stakeholders\",     \"description\": \"Send email report\",     \"depends_on\": ${ID16} }" ${DEST}/todos | jq ".id")
ID18=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Check inventory\"                                                                                        }" ${DEST}/todos | jq ".id")
ID19=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Order necessary inventory\",         \"description\": \"Check stocks\",          \"depends_on\": ${ID18} }" ${DEST}/todos | jq ".id")
ID20=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Unpack and store inventory\",                                                    \"depends_on\": ${ID19} }" ${DEST}/todos | jq ".id")
ID21=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Update inventory system\",                                                       \"depends_on\": ${ID20} }" ${DEST}/todos | jq ".id")
ID22=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Plan marketing campaign\",           \"description\": \"Factor in report data\", \"depends_on\": ${ID12} }" ${DEST}/todos | jq ".id")
ID23=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Execute marketing campaign\",                                                    \"depends_on\": ${ID22} }" ${DEST}/todos | jq ".id")
ID24=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Assess campaign success\",           \"description\": \"Study analytics\",       \"depends_on\": ${ID23} }" ${DEST}/todos | jq ".id")
ID25=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Plan product improvements\",                                                     \"depends_on\": ${ID24} }" ${DEST}/todos | jq ".id")
ID26=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Discuss improvements with team\",                                                \"depends_on\": ${ID25} }" ${DEST}/todos | jq ".id")
ID27=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Implement agreed improvements\",     \"description\": \"Align with team\",       \"depends_on\": ${ID26} }" ${DEST}/todos | jq ".id")
ID28=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Revise business plan\",                                                          \"depends_on\": ${ID17} }" ${DEST}/todos | jq ".id")
ID29=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Review job applications\",                                                       \"depends_on\": ${ID13} }" ${DEST}/todos | jq ".id")
ID30=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Interview candidates\",              \"description\": \"Verify skills in CVs\",  \"depends_on\": ${ID29} }" ${DEST}/todos | jq ".id")
ID31=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Train new hire\",                                                                \"depends_on\": ${ID30} }" ${DEST}/todos | jq ".id")
ID32=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Manage client contract renewals\",                                               \"depends_on\": ${ID14} }" ${DEST}/todos | jq ".id")
ID33=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Review and update company website\", \"description\": \"Update blog section\",   \"depends_on\": ${ID31} }" ${DEST}/todos | jq ".id")
ID34=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Pay company bills\",                                                             \"depends_on\": ${ID17} }" ${DEST}/todos | jq ".id")
ID35=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Process team payroll\",              \"description\": \"Check hours worked\",    \"depends_on\": ${ID13} }" ${DEST}/todos | jq ".id")
ID36=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Attend industry webinar\",                                                       \"depends_on\": ${ID27} }" ${DEST}/todos | jq ".id")
ID37=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Write and publish blog post\",                                                   \"depends_on\": ${ID33} }" ${DEST}/todos | jq ".id")
ID37=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Write and publish blog post\",                                                   \"depends_on\": ${ID33} }" ${DEST}/todos | jq ".id")
ID38=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Plan next quarter goals\",           \"description\": \"Refer business plan\",   \"depends_on\": ${ID28} }" ${DEST}/todos | jq ".id")
ID39=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Bake cake\",                         \"description\": \"Cheesecake :)\",         \"depends_on\": ${ID04} }" ${DEST}/todos | jq ".id")
ID40=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Make omelette\",                                                                 \"depends_on\": ${ID03} }" ${DEST}/todos | jq ".id")
ID41=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Clean garage\",                      \"description\": \"\"                                               }" ${DEST}/todos | jq ".id")
ID42=$(curl -X POST -H "content-type: application/json" --data "{ \"title\": \"Visit parents\",                                                                 \"depends_on\": ${ID39} }" ${DEST}/todos | jq ".id")
