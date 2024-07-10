# SecureAPIProxy

**SecureAPIProxy** is an efficient and reliable API protection system designed to prevent malicious attacks and ensure that only legitimate users can access your API.

## Features

- **User Authentication**: Authenticate users using UUID and token stored in Redis.
- **Request Verification**: Check the request token; if invalid, return 403 and log the failure. After three failures, add the IP to the Redis blacklist for 24 hours.
- **IP Blacklisting**: Add IPs with repeated failures to a Redis blacklist, blocking them for 24 hours.
- **Secure Forwarding**: Forward valid requests to the real API with a specific OAuth header.
- **Real-time Sync**: Use MySQL Binlog to sync user data to Redis in real-time.

## Project Structure

```plaintext
SecureAPIProxy/
├── README.md
├── docker-compose.yml
├── nginx/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── lua/
│       └── check_token.lua
├── sync/
│   ├── Dockerfile
│   └── binlog_to_redis.go
└── init/
    ├── init.sql
    └── Dockerfile
```

## Getting Started

1. Clone the Repository
```bash
git clone https://github.com/yourusername/SecureAPIProxy.git
cd SecureAPIProxy
```

2. Build and Start the Services
```bash
docker-compose up --build
```
