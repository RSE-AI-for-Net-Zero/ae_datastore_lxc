import os
import sys
import requests
from pprint import pprint

BASEURL = "https://data-dev.ae.ic.ac.uk/api"
TOKEN = os.environ.get("TOKEN", None)
COMMUNITY_SLUG = "test2"

verify = True

if not TOKEN:
    sys.exit("TOKEN not set")


#0. Get community ID
query_string = f"slug:{COMMUNITY_SLUG}"

r = requests.get(f"{BASEURL}/communities",
                 params = {"q": query_string},
                 verify = verify)


assert r.status_code == 200 #OK
assert r.json()["hits"]["total"] == len(r.json()["hits"]["hits"]) == 1
community_id = r.json()["hits"]["hits"][0]["id"]

#1. Create new record
r = requests.post(f"{BASEURL}/records",
                  params = {"access_token": TOKEN},
                  verify = verify)

assert r.status_code == 201 #Created
record = r.json()
record_id = record["id"]

#2. Add to community
r = requests.put(f"{BASEURL}/records/{record_id}/draft/review",
                 params = {"access_token": TOKEN},
                 json = {"receiver": {"community": community_id}, "type": "community-submission"},
                 verify = verify)



#3. Add some invalid domain metadata to record 
record["metadata"] = {"domain_metadata": {"entry_type": {"longitude": 22.0,
                                                         "laaaatitude": 22.0}}}
r = requests.put(f"{BASEURL}/records/{record_id}/draft",
                 params = {"access_token": TOKEN},
                 verify = verify,
                 json = record)

assert r.status_code == 422 # Is this an appropriate status_code?
assert "{\'longitude\': 22.0, \'laaaatitude\': 22.0} is not valid under any of the given schemas" in r.text



#4. Add required metadata & some valid domain metadata to record
record["metadata"] = {"domain_metadata": {"entry_type": {"longitude": 22.0,
                                                         "latitude": 22.0}}}
r = requests.put(f"{BASEURL}/records/{record_id}/draft",
                 params = {"access_token": TOKEN},
                 verify = verify,
                 json = record)

assert r.status_code == 200 #OK
assert r.json()["metadata"] == {"domain_metadata": {"entry_type": {"longitude": 22.0,
                                                                   "latitude": 22.0}}}
record["metadata"]["creators"] = [
    {
        "person_or_org": {
            "family_name": "Star",
            "given_name": "Patrick",
            "type": "personal",
            "identifiers": [
                {
                    "scheme": "orcid",
                    "identifier": "0000-0002-1825-0097"
            }
            ]
        },
        "role": {
            "id": "contactperson"
    },
        "affiliations": []
    }]

record["metadata"]["resource_type"] = {
    "id": "publication-conferencepaper"
}

record["metadata"]["title"] = "Test record!"
record["metadata"]["publication_date"] = "1970/2016-06"

r = requests.put(f"{BASEURL}/records/{record_id}/draft",
                 params = {"access_token": TOKEN},
                 verify = verify,
                 json = record)


#5. Start file upload
data = [{"key": "spongebob.png"}, {"key": "ideal-hash-trees.pdf"}]

r = requests.post(f"{BASEURL}/records/{record_id}/draft/files",
                  params = {"access_token": TOKEN},
                  verify = verify,
                  json = data)

assert r.status_code == 201 #Created

#6. Upload the files
with open("tests/test_files/spongebob.png", "rb") as f:
    filename = "spongebob.png"
    r = requests.put(f"{BASEURL}/records/{record_id}/draft/files/{filename}/content",
                     params = {"access_token": TOKEN},
                     verify = verify,
                     data = f)

assert r.status_code == 200 #OK
    
with open("tests/test_files/idealhashtrees.pdf", "rb") as f:
    filename = "ideal-hash-trees.pdf"
    r = requests.put(f"{BASEURL}/records/{record_id}/draft/files/{filename}/content",
                     params = {"access_token": TOKEN},
                     verify = verify,
                     data = f)

assert r.status_code == 200 #OK

#7. Complete draft file upload
filename = "spongebob.png"
r = requests.post(f"{BASEURL}/records/{record_id}/draft/files/{filename}/commit",
                  params = {"access_token": TOKEN},
                  verify = verify)

assert r.status_code == 200 #OK

filename = "ideal-hash-trees.pdf"
r = requests.post(f"{BASEURL}/records/{record_id}/draft/files/{filename}/commit",
                  params = {"access_token": TOKEN},
                  verify = verify)

assert r.status_code == 200 #OK

#8. Delete a file
filename = "ideal-hash-trees.pdf"
r = requests.delete(f"{BASEURL}/records/{record_id}/draft/files/{filename}",
                    params = {"access_token": TOKEN},
                    verify = verify)

assert r.status_code == 204 #No Content

#9. Request review
r = requests.post(f"{BASEURL}/records/{record_id}/draft/actions/submit-review",
                  params = {"access_token": TOKEN},
                  verify = verify,
                  json = {"payload": {"content": "Thanking you kindly", "format": "html"}})




