import os
import sys
import requests
from pprint import pprint

BASEURL = "https://data-dev.ae.ic.ac.uk/api"
TOKEN = os.environ.get("TOKEN", None)
COMMUNITY_SLUG = "test-community"

verify = True

if not TOKEN:
    sys.exit("TOKEN not set")


"""
Request to publish draft created in REST_access_token_CRUD_community_pt1.py has been
accepted
"""

#0. Get community ID
query_string = f"slug:{COMMUNITY_SLUG}"

r = requests.get(f"{BASEURL}/communities",
                 params = {"q": query_string},
                 verify = verify)


assert r.status_code == 200 #OK
assert r.json()["hits"]["total"] == len(r.json()["hits"]["hits"]) == 1
community_id = r.json()["hits"]["hits"][0]["id"]


#1. Find our record
r = requests.get(f"{BASEURL}/records",
                 params = {"q": "title:Test Record"},
                 verify = verify)

assert r.status_code == 200 #OK
assert r.json()["hits"]["total"] == 1
record_id = r.json()["hits"]["hits"][0]["id"]

#2. Create a new draft from published record
r = requests.post(f"{BASEURL}/records/{record_id}/versions",
                  params = {"access_token": TOKEN},
                  verify = verify)

assert r.status_code == 201 #Created
assert r.json()["versions"]["is_latest"] is False
assert r.json()["versions"]["is_latest_draft"] is True
assert r.json()["is_published"] is False

record_id = r.json()["id"]
record = r.json()

#3. Try and add this new draft to community "test-community"
r = requests.put(f"{BASEURL}/records/{record_id}/draft/review",
                 params = {"access_token": TOKEN},
                 json = {"receiver": {"community": community_id}, "type": "community-submission"},
                 verify = verify)

assert r.status_code == 400
assert '"message": "You cannot create a review for an already published record."' in r.text

#4. Hmm, ok let's update the metadata anyway - notice that "test-community" still appears
#     on GUI upload page
record["metadata"]["publication_date"] = "2025-03-27"
record["metadata"]["description"] = "Colour is now blue"
record["metadata"]["domain_metadata"]["entry_type"]["colour"] = "blue"

r = requests.put(f"{BASEURL}/records/{record_id}/draft",
                 params = {"access_token": TOKEN},
                 verify = verify,
                 json = record)
                 
#5. Link files from previous version
r = requests.post(f"{BASEURL}/records/{record_id}/draft/actions/files-import",
                  params = {"access_token": TOKEN},
                  verify = verify)

assert r.status_code == 201 #Created

#6. Add another file
data = [{"key": "ideal-hash-trees.pdf"}]

r = requests.post(f"{BASEURL}/records/{record_id}/draft/files",
                  params = {"access_token": TOKEN},
                  verify = verify,
                  json = data)

assert r.status_code == 201 #Created

with open("tests/test_files/idealhashtrees.pdf", "rb") as f:
    filename = "ideal-hash-trees.pdf"
    r = requests.put(f"{BASEURL}/records/{record_id}/draft/files/{filename}/content",
                     params = {"access_token": TOKEN},
                     verify = verify,
                     data = f)

assert r.status_code == 200 #OK

r = requests.post(f"{BASEURL}/records/{record_id}/draft/files/{filename}/commit",
                  params = {"access_token": TOKEN},
                  verify = verify)

assert r.status_code == 200 #OK



#7. Publish
r = requests.post(f"{BASEURL}/records/{record_id}/draft/actions/publish",
                  params = {"access_token": TOKEN},
                  verify = verify)

assert r.status_code == 202 #Accepted

                  








