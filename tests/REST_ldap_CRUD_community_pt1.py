import os
import sys
import requests
from pprint import pprint

BASEURL = "https://data-dev.ae.ic.ac.uk/api"
USERNAME = "testuser"
PASSWD = os.environ.get("PASSWD", None)
COMMUNITY_SLUG = "test-community"

verify = True

if not PASSWD:
    sys.exit("PASSWD not set")


"""
Community "test-community" has been created and user identity linked to the access token
has permissions to create drafts, etc.
"""

#0. Log in and store session and csrf cookies - web browser would perhaps do this
#    automatically
r = requests.post(f"{BASEURL}/login",
                  json = {"username": USERNAME,
                          "password": PASSWD},
                  verify = False)

cookies = r.cookies
csrftoken = cookies["csrftoken"]
session = cookies["session"]

# Notice Referer (not a typo) header has to be one of the trusted hosts - also needs https
headers = {"X-CSRFToken": csrftoken, "Referer": "https://data-dev.ae.ic.ac.uk"}


#1. Get community ID
query_string = f"slug:{COMMUNITY_SLUG}"

r = requests.get(f"{BASEURL}/communities",
                 params = {"q": query_string},
                 verify = verify)


assert r.status_code == 200 #OK
assert r.json()["hits"]["total"] == len(r.json()["hits"]["hits"]) == 1
community_id = r.json()["hits"]["hits"][0]["id"]

#2. Create new record
r = requests.post(f"{BASEURL}/records",
                  cookies = dict(session=session, csrftoken=csrftoken),
                  headers = headers,
                  verify = verify)

assert r.status_code == 201 #Created
record = r.json()
record_id = record["id"]


#3. Add required metadata & some valid domain metadata to record
record["metadata"] = {"domain_metadata": {"entry_type": {"longitude": 22.0,
                                                         "latitude": 22.0}}}
r = requests.put(f"{BASEURL}/records/{record_id}/draft",
                 cookies = dict(session=session, csrftoken=csrftoken),
                 headers = headers,
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

record["metadata"]["title"] = "Another test record!"
record["metadata"]["publication_date"] = "2025-03-27"

r = requests.put(f"{BASEURL}/records/{record_id}/draft",
                 cookies = dict(session=session, csrftoken=csrftoken),
                 headers = headers,
                 verify = verify,
                 json = record)

assert r.status_code == 200 #OK

#4. Add to community
r = requests.put(f"{BASEURL}/records/{record_id}/draft/review",
                 cookies = dict(session=session, csrftoken=csrftoken),
                 headers = headers,
                 json = {"receiver": {"community": community_id}, "type": "community-submission"},
                 verify = verify)

#5. Start file upload
data = [{"key": "spongebob.png"}, {"key": "ideal-hash-trees.pdf"}]

r = requests.post(f"{BASEURL}/records/{record_id}/draft/files",
                  cookies = dict(session=session, csrftoken=csrftoken),
                  headers = headers,
                  verify = verify,
                  json = data)

assert r.status_code == 201 #Created

#6. Upload the files
with open("tests/test_files/spongebob.png", "rb") as f:
    filename = "spongebob.png"
    r = requests.put(f"{BASEURL}/records/{record_id}/draft/files/{filename}/content",
                     cookies = dict(session=session, csrftoken=csrftoken),
                     headers = headers,
                     verify = verify,
                     data = f)

assert r.status_code == 200 #OK
    
with open("tests/test_files/idealhashtrees.pdf", "rb") as f:
    filename = "ideal-hash-trees.pdf"
    r = requests.put(f"{BASEURL}/records/{record_id}/draft/files/{filename}/content",
                     cookies = dict(session=session, csrftoken=csrftoken),
                     headers = headers,
                     verify = verify,
                     data = f)

assert r.status_code == 200 #OK

#7. Complete draft file upload
filename = "spongebob.png"
r = requests.post(f"{BASEURL}/records/{record_id}/draft/files/{filename}/commit",
                  cookies = dict(session=session, csrftoken=csrftoken),
                  headers = headers,
                  verify = verify)

assert r.status_code == 200 #OK

filename = "ideal-hash-trees.pdf"
r = requests.post(f"{BASEURL}/records/{record_id}/draft/files/{filename}/commit",
                  cookies = dict(session=session, csrftoken=csrftoken),
                  headers = headers,
                  verify = verify)

assert r.status_code == 200 #OK

#8. Request review
r = requests.post(f"{BASEURL}/records/{record_id}/draft/actions/submit-review",
                  cookies = dict(session=session, csrftoken=csrftoken),
                  headers = headers,
                  json = {"payload": {"content": "Thanking you kindly", "format": "html"}})

assert r.status_code == 202 #Accepted

"""
Record is accepted via GUI
"""

#9. Log out
r = requests.post(f"{BASEURL}/logout",
                  cookies = dict(session=session, csrftoken=csrftoken),
                  headers = headers)

assert r.status_code == 200 #Ok
assert "User logged out." in r.text



