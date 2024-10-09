=====================
Directory
=====================

---------------------------
Bind bases, dn and username
---------------------------
User info stored in several locations in the *directory information tree* (DIT), e.g,

local users: ``ou=People,ou=Local,o=Example,dc=example,dc=com``
external users: ``ou=People,o=Example,dc=example,dc=com``
special users: ``ou=People,ou=Something,ou=Special,o=Example,dc=example,dc``

We call these *bind bases*.  Each user (like all DIT entries) is uniquely identified by their *distinguished name* (dn), e.g., ``dn: uid=spongebob,ou=People,o=Example,dc=example,dc=com``

We provide lambdas for converting a username into a dn

``lambda user : f'uid={user},ou=People,o=Example,dc=example,dc=com'``


And (potentially) a dict mapping bind bases to callables that parsing a dn and extract a
username

---------------------------
User aliases
---------------------------
LDAP provdes a way to alias an entry and assign arbitrary attributes to the alias

``objectclass=alias,extensibleObject``
``attribute=aliasedObjectName``

Possible scenario:

Notes:

aliasedObjectName has EQUALITY distinguishedNameMatch matching rule,
i.e., you cannot query a substring (rfc4512 2.6.2) it either matches in full or doesn't at all

see:
https://stackoverflow.com/questions/54616977/ldap-filter-in-dn-string-attribute

invenio_accounts.models.User

=========       ======          ========     
Column		unique		nullable
=========       ======          ========     
_username	True		True
_email       	True		(True)
=========       ======          ========     

What if:

- Two distinct people have the same username - possible because they sit beneath different bind
  bases
- One person has two usernames - these could sit under the same or distinct bind bases
- One person, sitting in one place in the DIT, has multiple email addresses
- A person has an alias in the DIT, either under the same or a different bind base


---------------------------
Login process
---------------------------

^^^^^^^^^^^^^^^^^^^^^^^^^^^
Assumptions
^^^^^^^^^^^^^^^^^^^^^^^^^^^


^^^^^^^^^^^^^^^^^^^^^^^^^^^
Process
^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. View factory

 - Internal login view
 - External login views

Or

2. One login view with radio button
   

Assuming option 2 for now::

  POST /<ldap_login_url>/

  data = {username=<username>,
          password=<password>,
	  bind_base_key=<key>}

**ASSUMPTION** the login view function receives enough information to contruct the user's dn, bearing in mind the user's entry may sit in one of several locations in the DIT.  E.g., the login endpoint::

  invenio_ldapclient.views.login_via_ldap

maps the ``bind_base_key`` argument from the request to a bind base via config.

We construct the form object and, for certain methods including POST, we use data from the request to populate the form's fields.  Since method is ``POST``,  ``validate_on_submit`` depends directly upon what the form's ``validate()`` method returns.

Validation steps:
 1. username, password and bind key are provided (or sufficient information is provided at this point to construct user's dn and password) - or, do we iterate through bind bases transparently to user?  Or do we bind with a fixed account and search the DIT for an email address?
 2. LDAP ``bind()`` returns ``True``
 3. group membership condition is satisfied
 4. user search returns at least one entry (do we check for aliases here?)
 5. one of user's entries has an ``<email>`` attribute

<Flow diagram for email option>

We then need to perform a bind operation.  Options for this are ``simple`` and ``SASL`` - the latter
implies numerous sub-options and are server dependent.  After reading the server's schema defintion, using LDAP3, ::

  server.info.supported_sasl_mechanisms

returns list of supported mechanisms.  ``invenio-ldapclient`` v1.0.0 uses ``simple``.

Simple bind requires passing user's distinguished name and password as ``user`` and ``password`` arguments to LDAP3's Connection constructor, then calling the returned Connection object ``.bind()`` method.



