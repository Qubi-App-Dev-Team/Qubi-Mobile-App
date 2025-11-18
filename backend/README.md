# Instructions to Run API Server Locally 
* Make sure you are in the folder backend/ 
* Run the following command in terminal: ```uvicorn main:app --reload```
* Server should be up and running, frontend should be able to make requests
* To open a GUI and test api calls visit http://127.0.0.1:8000/docs#/ in your browser 
* Ctrl + C in the terminal to terminate server
* Need a ```.env``` in backend folder (ask a member of team for it)


## For the streamlit dashboard
For the streamlit learn content dashboard (site that allows easy creation of learn pages)  
you need the secret file:
```backend/learn_content/service_account.json```