==================================
Inspecting register/login workflow
==================================

----------------------------------
Browser development tips
----------------------------------

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Mimicking a browser request
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For debugging purposes, it's useful when sending a request to the app to be able to immitate a web browser using cURL or  Python's `requests package <https://requests.readthedocs.io/en/latest/>`_.  Firefox is helpful in making sure you have the right request header values set (e.g., the session cookie id and the CSRF token)


1. Open Developer Tools - ``Ctrl + Shift + I``
2. Open the *Network* tab
3. Do something to trigger the browser to send the request - e.g., register a new user
4. You'll see details of a number of requests sent by the browser.  The one you're most interested is probably the POST request that's at the top of the list
5. Right click on this request, select *Copy Value* then select, e.g., *Copy as cURL*
6. Paste this somewhere

