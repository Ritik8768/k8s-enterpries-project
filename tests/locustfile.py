from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 3)  # Wait 1-3 seconds between requests
    host = "http://api.local"
    
    @task(3)  # Weight: 3 (most common)
    def get_api_data(self):
        self.client.get("/api/data")
    
    @task(2)  # Weight: 2
    def get_health(self):
        self.client.get("/health")
    
    @task(2)  # Weight: 2
    def get_ready(self):
        self.client.get("/ready")
    
    @task(1)  # Weight: 1
    def get_metrics(self):
        self.client.get("/metrics")
    
    @task(1)  # Weight: 1 (least common)
    def get_home(self):
        self.client.get("/")
