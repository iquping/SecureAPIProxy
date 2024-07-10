package main

import (
    "context"
    "log"

    "github.com/go-redis/redis/v8"
    "github.com/siddontang/go-mysql/canal"
    "github.com/siddontang/go-mysql/mysql"
)

var (
    ctx       = context.Background()
    redisAddr = "redis:6379"
    redisDB   = 0
    redisPass = ""
)

type MyEventHandler struct {
    canal.DummyEventHandler
    redisClient *redis.Client
}

func (h *MyEventHandler) OnRow(e *canal.RowsEvent) error {
    if e.Table.Schema == "secureapi" && e.Table.Name == "v2_user" {
        for _, row := range e.Rows {
            uuid := row[0].(string)
            token := row[1].(string)
            err := h.redisClient.Set(ctx, token, uuid, 0).Err()
            if err != nil {
                log.Printf("Error setting key in Redis: %v", err)
            } else {
                log.Printf("UUID %s with token %s synced to Redis", uuid, token)
            }
        }
    }
    return nil
}

func main() {
    redisClient := redis.NewClient(&redis.Options{
        Addr:     redisAddr,
        Password: redisPass,
        DB:       redisDB,
    })

    cfg := canal.NewDefaultConfig()
    cfg.Addr = "mysql:3306"
    cfg.User = "user"
    cfg.Password = "password"
    cfg.Flavor = "mysql"

    c, err := canal.NewCanal(cfg)
    if err != nil {
        log.Fatal(err)
    }

    h := &MyEventHandler{redisClient: redisClient}
    c.SetEventHandler(h)

    pos, err := c.GetMasterPos()
    if err != nil {
        log.Fatal(err)
    }

    err = c.StartFrom(pos)
    if err != nil {
        log.Fatal(err)
    }

    select {}
}
