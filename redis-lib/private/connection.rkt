#lang racket/base

(require racket/class
         racket/list
         racket/tcp
         "protocol.rkt")

(provide
 redis%)

(define redis%
  (class object%
    (init-field [ip "127.0.0.1"]
                [port 6379]
                [timeout 1])

    (field [out #f]
           [in #f])

    (super-new)

    (define/private (send proc)
      (parameterize ([current-output-port out])
        (proc)
        (flush-output)))

    (define/private (get-response)
      (let loop ([resp ""])
        (let ([p (sync/timeout timeout in)])
          (if (input-port? p)
              (let ([s (read-line p)])
                (if (eof-object? s)
                    (if (not (equal? resp ""))
                        (redis-decode resp)
                        "ERR timed out")
                    (loop (string-append resp s "\n"))))
              (if (not (equal? resp ""))
                  (redis-decode resp)
                  "ERR timed out")))))

    (define/private (apply-cmd cmd [args null])
      (if (null? args)
          (send (lambda _
                  (display cmd)
                  (display "\r\n")))
          (send (lambda _
                  (redis-encode  (append (list cmd) (if (list? args) args (list args))))))))

    (define/public (set-timeout t)
      (set! timeout t))

    (define/public (ping [msg null])
      (apply-cmd "PING" msg)
      (get-response))

    (define/public (auth password)
      (apply-cmd "AUTH" password)
      (get-response))

    (define/public (echo msg)
      (apply-cmd "ECHO" msg)
      (get-response))

    (define/public (select index)
      (apply-cmd "SELECT" index)
      (get-response))

    (define/public (quit)
      (apply-cmd "QUIT")
      (get-response))

    (define/public (exists keys)
      (apply-cmd "EXISTS" keys)
      (get-response))

    (define/public (set key value)
      (apply-cmd "SET" (list key value))
      (get-response))

    (define/public (get key)
      (apply-cmd "GET" key)
      (get-response))

    (define/public (mget keys)
      (apply-cmd "MGET" keys)
      (get-response))

    (define/public (mset data)
      (apply-cmd "MSET" data)
      (get-response))

    (define/public (msetnx data)
      (apply-cmd "MSETNX" data)
      (get-response))

    (define/public (getset key value)
      (apply-cmd "GETSET" (list key value))
      (get-response))

    (define/public (incr key)
      (apply-cmd "INCR" key)
      (get-response))

    (define/public (incrby key value)
      (apply-cmd "INCRBY" (list key value))
      (get-response))

    (define/public (decr key)
      (apply-cmd "DECR" key)
      (get-response))

    (define/public (decrby key value)
      (apply-cmd "DECRBY" (list key value))
      (get-response))

    (define/public (del key)
      (apply-cmd "DEL" key)
      (get-response))

    (define/public (setnx key value)
      (apply-cmd "SETNX" (list key value))
      (get-response))

    (define/public (lpush key value)
      (apply-cmd "LPUSH" (if (list? value)
                             (append (list key) value)
                             (list key value)))
      (get-response))

    (define/public (rpush key value)
      (apply-cmd "RPUSH" (if (list? value)
                             (append (list key) value)
                             (list key value)))
      (get-response))

    (define/public (lrange key min max)
      (apply-cmd "LRANGE" (list key min max))
      (get-response))

    (define/public (ltrim key start end)
      (apply-cmd "LTRIM" (list key start end))
      (get-response))

    (define/public (lindex key index)
      (apply-cmd "LINDEX" (list key index))
      (get-response))

    (define/public (lset key index value)
      (apply-cmd "LSET" (list key index value))
      (get-response))

    (define/public (lpop key string)
      (apply-cmd "LPOP" (list key string))
      (get-response))

    (define/public (rpop key string)
      (apply-cmd "RPOP" (list key string))
      (get-response))

    (define/public (blpop keys timeout)
      (apply-cmd "BLPOP" (append keys (list timeout)))
      (get-response))

    (define/public (brpop keys timeout)
      (apply-cmd "BRPOP" (append keys (list timeout)))
      (get-response))

    (define/public (rpoplpush srckey destkey)
      (apply-cmd "RPOPLPUSH" (list srckey destkey))
      (get-response))

    (define/public (sadd key member)
      (apply-cmd "SADD" (list key member))
      (get-response))

    (define/public (srem key member)
      (apply-cmd "SREM" (list key member))
      (get-response))

    (define/public (spop key)
      (apply-cmd "SPOP" key)
      (get-response))

    (define/public (srandmember key)
      (apply-cmd "SRANDMEMBER" key)
      (get-response))

    (define/public (smove srckey destkey member)
      (apply-cmd "SMOVE" (list srckey destkey member))
      (get-response))

    (define/public (scard key)
      (apply-cmd "SCARD" key)
      (get-response))

    (define/public (sismember key member)
      (apply-cmd "SISMEMBER" (list key member))
      (get-response))

    (define/public (sinter keys)
      (apply-cmd "SINTER" keys)
      (get-response))

    (define/public (sinterstore destkey srckeys)
      (apply-cmd "SINTERSTORE" (list destkey srckeys))
      (get-response))

    (define/public (sunion keys)
      (apply-cmd "SUNION" keys)
      (get-response))

    (define/public (sunionstore destkey srckeys)
      (apply-cmd "SUNIONSTORE" (list destkey srckeys))
      (get-response))

    (define/public (sdiff keys)
      (apply-cmd "SDIFF" keys)
      (get-response))

    (define/public (sdiffstore destkey srckeys)
      (apply-cmd "SDIFFSTORE" (list destkey srckeys))
      (get-response))

    (define/public (smembers key)
      (apply-cmd "SMEMBERS" key)
      (get-response))

    (define/public (zadd key data)
      (apply-cmd "ZADD" (append (list key) data))
      (get-response))

    (define/public (zrem key member)
      (apply-cmd "ZREM" (append (list key) (if (list? member) member (list member))))
      (get-response))

    (define/public (zincrby key incr member)
      (apply-cmd "ZINCRBY" (list key incr member))
      (get-response))

    (define/public (zrange key start end)
      (apply-cmd "ZRANGE" (list key start end))
      (get-response))

    (define/public (zrevrange key start end)
      (apply-cmd "ZREVRANGE" (list key start end))
      (get-response))

    (define/public (zrangebyscore key min max)
      (apply-cmd "ZRANGEBYSCORE" (list key min max))
      (get-response))

    (define/public (zremrangebyscore key min max)
      (apply-cmd "ZREMRANGEBYSCORE" (list key min max))
      (get-response))

    (define/public (zcard key)
      (apply-cmd "ZCARD" key)
      (get-response))

    (define/public (zscore key member)
      (apply-cmd "ZSCORE" (list key member))
      (get-response))

    (define/public (zlexcount key min max)
      (apply-cmd "ZLEXCOUNT" (list key min max))
      (get-response))

    (define/public (zrangebylex key min max)
      (apply-cmd "ZRANGEBYLEX" (list key min max))
      (get-response))

    (define/public (zinterstore dest keys)
      (apply-cmd "ZINTERSTORE" (append (list dest) keys))
      (get-response))

    (define/public (zcount key min max)
      (apply-cmd "ZCOUNT" (list key min max))
      (get-response))

    (define/public (zrevrank key member)
      (apply-cmd "ZREVRANK" (list key member))
      (get-response))

    (define/public (zrevrangebyscore key max min)
      (apply-cmd "ZREVRANGEBYSCORE" (list key max min))
      (get-response))

    (define/public (zremrangebyrank key start stop)
      (apply-cmd "ZREMRANGEBYSCORE" (list key start stop))
      (get-response))

    (define/public (zremrangebylex key min max)
      (apply-cmd "ZREMRANGEBYLEX" (list key min max))
      (get-response))

    (define/public (zunionstore dest keys)
      (apply-cmd "ZUNIONSTORE" (append (list dest) keys))
      (get-response))

    (define/public (hmset key data)
      (apply-cmd "HMSET" (append (list key) data))
      (get-response))

    (define/public (hvals key)
      (apply-cmd "HVALS" key)
      (get-response))

    (define/public (hdel key fields)
      (apply-cmd "HDEL" (append (list key) fields))
      (get-response))

    (define/public (hsetnx key field value)
      (apply-cmd "HSETNX" (list key field value))
      (get-response))

    (define/public (hget key field)
      (apply-cmd "HGET" (list key field))
      (get-response))

    (define/public (hgetall key)
      (apply-cmd "HGETALL" key)
      (get-response))

    (define/public (hincrby key field increment)
      (apply-cmd "HINCRBY" (list key field increment))
      (get-response))

    (define/public (hexists key field)
      (apply-cmd "HEXISTS" (list key field))
      (get-response))

    (define/public (hkeys key)
      (apply-cmd "HKEYS" key)
      (get-response))

    (define/public (hlen key)
      (apply-cmd "HLEN" key)
      (get-response))

    (define/public (concat key value)
      (apply-cmd "APPEND" (list key value))
      (get-response))

    (define/public (strlen key)
      (apply-cmd "STRLEN" key)
      (get-response))

    (define/public (bitcount key [start "0"] [end (number->string (string-length key))])
      (apply-cmd "BITCOUNT" (list key start end))
      (get-response))

    (define/public (bitop operation destkey key)
      (apply-cmd "BITOP" (append (list operation destkey) (if (list? key) key (list key))))
      (get-response))

    (define/public (bitpos key bit [start null] [end null])
      (apply-cmd "BITPOS" (flatten (list key bit start end)))
      (get-response))

    (define/public (watch key)
      (apply-cmd "WATCH" key)
      (get-response))

    (define/public (unwatch)
      (apply-cmd "UNWATCH")
      (get-response))

    (define/public (getrange key start end)
      (apply-cmd "GETRANGE" (list key start end))
      (get-response))

    (define/public (type key)
      (apply-cmd "TYPE" key)
      (get-response))

    (define/public (keys pattern)
      (apply-cmd "KEYS" pattern)
      (get-response))

    (define/public (randomkey)
      (apply-cmd "RANDOMKEY")
      (get-response))

    (define/public (rename oldkey newkey)
      (apply-cmd "RENAME" (list oldkey newkey))
      (get-response))

    (define/public (renamex oldkey newkey)
      (apply-cmd "RENAMEX" (list oldkey newkey))
      (get-response))

    (define/public (config-get parameter)
      (apply-cmd "CONFIG GET" parameter)
      (get-response))

    (define/public (config-set parameter value)
      (apply-cmd "CONFIG SET" (list parameter value))
      (get-response))

    (define/public (config-rewrite)
      (apply-cmd "CONFIG REWRITE")
      (get-response))

    (define/public (config-resetstat)
      (apply-cmd "CONFIG RESETSTAT")
      (get-response))

    (define/public (dbsize)
      (apply-cmd "DBSIZE")
      (get-response))

    (define/public (expire key seconds)
      (apply-cmd "EXPIRE" (list key seconds))
      (get-response))

    (define/public (expireat key unixtime)
      (apply-cmd "EXPIREAT" (list key unixtime))
      (get-response))

    (define/public (ttl key)
      (apply-cmd "TTL" key)
      (get-response))

    (define/public (move key index)
      (apply-cmd "MOVE" (list key index))
      (get-response))

    (define/public (flushdb)
      (apply-cmd "FLUSHDB")
      (get-response))

    (define/public (flushall)
      (apply-cmd "FLUSHALL")
      (get-response))

    (define/public (save)
      (apply-cmd "SAVE")
      (get-response))

    (define/public (bgsave)
      (apply-cmd "BGSAVE")
      (get-response))

    (define/public (lastsave)
      (apply-cmd "LASTSAVE")
      (get-response))

    (define/public (bgrewriteaof)
      (apply-cmd "BGREWRITEAOF")
      (get-response))

    (define/public (shutdown)
      (apply-cmd "SHUTDOWN")
      (get-response))

    (define/public (info)
      (apply-cmd "INFO")
      (get-response))

    (define/public (monitor)
      (apply-cmd "MONITOR")
      (get-response))

    (define/public (object subcommand [args null])
      (apply-cmd "OBJECT" (append (list subcommand) args))
      (get-response))

    (define/public (slaveof host port)
      (apply-cmd "SLAVEOF" (list host port))
      (get-response))

    (define/public (subscribe channel)
      (apply-cmd "SUBSCRIBE" channel)
      (get-response))

    (define/public (publish channel msg)
      (apply-cmd "PUBLISH" (list channel msg))
      (get-response))

    (define/public (unsubscribe channel)
      (apply-cmd "UNSUBSCRIBE" channel)
      (get-response))

    (define/public (psubscribe pattern)
      (apply-cmd "PSUBSCRIBE" pattern)
      (get-response))

    (define/public (punsubscribe pattern)
      (apply-cmd "PUNSUBSCRIBE" pattern)
      (get-response))

    (define/public (connect)
      (define-values (i o)
        (tcp-connect ip port))

      (set! in i)
      (set! out o))))

(module+ test
  (require rackunit)

  (define redis
    (new redis%))

  (send redis set-timeout 0.3)
  (send redis connect)

  (check-equal? (send redis config-resetstat) "OK")
  (check-equal? (send redis ping) "PONG" )
  (check-equal? (send redis ping "yo watup") "yo watup")
  (check-equal? (send redis echo "HEYY") "HEYY")
  (check-equal? (send redis select "1") "OK")
  ; (check-equal? (send redis auth "password") "OK"))

  (check-equal? (send redis set "a-number" "1") "OK")
  (check-equal? (send redis exists "a-number") 1)
  (check-equal? (send redis exists "some crap") 0)
  (check-equal? (send redis get "a-number") "1")
  (check-equal? (send redis incr "a-number") 2)
  (check-equal? (send redis getset "a-number" "4") "2")
  (check-equal? (send redis get "a-number") "4")

  (check-equal? (send redis set "key1" "fksd") "OK")
  (check-equal? (send redis set "key2" "fdadsf") "OK")
  (check-equal? (send redis set "key3" "bdafg") "OK")
  ;(check-true (send redis exists (list "key1" "key2" "key3")))
  (check-equal? (send redis mget (list "key1" "key2" "key3"))
                (list "fksd" "fdadsf" "bdafg"))

  (check-true (number? (send redis lpush "some-list" "1")))
  (check-true (number? (send redis lpush "some-list" (list "1" "2" "3" "4" "5"))))
  (check-true (list? (send redis lrange "some-list" "0" "-1")))

  (check-equal? (send redis del "a-number") 1)
  (check-equal? (send redis set "a" "hey") "OK")
  (check-equal? (send redis set "b" "'ello") "OK")
  (check-equal? (send redis del (list "a" "b")) 2)

  (check-true (list? (member (send redis del "new-key") (list 0 1))))
  (check-equal? (send redis setnx "new-key" "Hello") 1)
  (check-equal? (send redis setnx "new-key" "World") 0)
  (check-equal? (send redis strlen "new-key") 5)
  (check-equal? (send redis concat "new-key" " world") 11)
  (check-equal? (send redis get "new-key") "Hello world")

  (check-equal? (send redis set "a-number" "1") "OK")
  (check-equal? (send redis decr "a-number") 0)
  (check-equal? (send redis incrby "a-number" "5") 5)
  (check-equal? (send redis decrby "a-number" "5") 0)

  (check-equal? (send redis hmset "blah" '("a-number" "1")) "OK")
  (check-equal? (send redis hsetnx "blah" "a-number" "2") 0)
  (check-equal? (send redis hget "blah" "a-number") "1")
  (check-equal? (send redis hgetall "blah") (list "a-number" "1"))
  (check-equal? (send redis hexists "blah" "a-number") 1)
  (check-equal? (send redis hexists "blah" "another-number") 0)
  (check-equal? (send redis hincrby "blah" "a-number" "2") 3)
  (check-equal? (send redis type "blah") "hash")
  (check-equal? (send redis hlen "blah") 1)

  (check-equal? (send redis watch "blah") "OK")
  (check-equal? (send redis unwatch) "OK")

  (check-equal? (send redis bitcount "a-number") 2)
  (check-equal? (send redis bitop "AND" "a-number" "a-number") 1)
  (check-equal? (send redis bitpos "a-number" "1") 2)
  (check-equal? (send redis getrange "a-number" "0" "1") "0")

  (check-equal? (send redis zadd "zset" (list "1" "one")) 1)
  (check-equal? (send redis zadd "zset" (list "1" "uno")) 1)
  (check-equal? (send redis zadd "zset" (list "2" "two" "3" "three")) 2)

  (check-equal? (send redis zrem "zset" "one") 1)
  (check-equal? (send redis zrem "zset" "uno") 1)
  (check-equal? (send redis zrem "zset" (list "two" "three")) 2)

  (check-equal? (send redis quit) "OK"))