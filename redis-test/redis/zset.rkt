#lang racket/base

(require rackunit
         redis
         "common.rkt")

(provide
 zset-tests)

(define zset-tests
  (test-suite
   "zset"

   (test-commands "basic sorted set commands"
     (check-equal? (redis-zset-add! test-client "a" "a" 1 "b" 2) 2)
     (check-equal? (redis-zset-add! test-client "a" "a" 1) 0)
     (check-equal? (redis-zset-count test-client "a") 2)
     (check-equal? (redis-zset-count test-client "a" #:min -inf.0 #:max +inf.0) 2)
     (check-equal? (redis-zset-count test-client "a" #:min 2 #:max +inf.0) 1)
     (check-equal? (redis-zset-count test-client "a" #:min -inf.0 #:max 1) 1)
     (check-equal? (redis-zset-count test-client "a" #:min 5 #:max 5) 0)
     (check-equal? (redis-zset-rank test-client "a" "a") 0)
     (check-equal? (redis-zset-rank test-client "a" "a" #:reverse? #t) 1)
     (check-equal? (redis-zset-rank test-client "a" "b") 1)
     (check-equal? (redis-zset-rank test-client "a" "b" #:reverse? #t) 0)
     (check-equal? (redis-zset-score test-client "a" "a") 1)
     (check-equal? (redis-zset-score test-client "a" "b") 2)
     (check-equal? (redis-zset-incr! test-client "a" "b" 1.5) 3.5)
     (check-equal? (redis-zset-incr! test-client "a" "b" -1.0) 2.5)
     (check-equal? (redis-zset-score test-client "a" "b") 2.5)
     (check-equal? (redis-zset-remove! test-client "a" "b") 1)
     (check-equal? (redis-zset-remove! test-client "a" "b") 0)
     (check-false (redis-zset-score test-client "a" "b"))
     (check-false (redis-zset-rank test-client "a" "b"))
     (check-equal? (redis-zset-count test-client "a") 1))

   (test-commands "sorted set intersections"
     (redis-zset-add! test-client "a" "a" 1 "b" 2)
     (redis-zset-add! test-client "b" "a" 1 "c" 3)
     (check-equal? (redis-zset-intersect! test-client "c" "a" "b") 1)
     (check-equal? (redis-zset-score test-client "c" "a") 2)
     (check-equal? (redis-zset-intersect! test-client "c" "a" "b" #:aggregate 'max) 1)
     (check-equal? (redis-zset-score test-client "c" "a") 1)
     (check-equal? (redis-zset-intersect! test-client "c" "a" "b" #:weights '(1 5) #:aggregate 'max) 1)
     (check-equal? (redis-zset-score test-client "c" "a") 5)

     (check-exn
      exn:fail:contract?
      (lambda _
        (redis-zset-intersect! test-client "c" "a" "b"
                           #:weights '(1)
                           #:aggregate 'max))))

   (test-commands "sorted set unions"
     (redis-zset-add! test-client "a" "a" 1 "b" 2)
     (redis-zset-add! test-client "b" "a" 1 "c" 3)
     (check-equal? (redis-zset-union! test-client "c" "a" "b") 3)
     (check-equal? (redis-zset-score test-client "c" "a") 2)
     (check-equal? (redis-zset-union! test-client "c" "a" "b" #:aggregate 'max) 3)
     (check-equal? (redis-zset-score test-client "c" "a") 1)
     (check-equal? (redis-zset-union! test-client "c" "a" "b" #:weights '(1 5) #:aggregate 'max) 3)
     (check-equal? (redis-zset-score test-client "c" "a") 5)

     (check-exn
      exn:fail:contract?
      (lambda _
        (redis-zset-union! test-client "c" "a" "b"
                           #:weights '(1)
                           #:aggregate 'max))))

   (test-commands "sorted set popping"
     (redis-zset-add! test-client "a" "a" 1 "b" 2 "c" 3)
     (check-equal? (redis-zset-pop/max! test-client "a" #:count 2)
                   '((#"c" . 3)
                     (#"b" . 2)))
     (check-equal? (redis-zset-pop/max! test-client "a" #:count 2)
                   '((#"a" . 1)))

     (redis-zset-add! test-client "a" "a" 1 "b" 2 "c" 3)
     (check-equal? (redis-zset-pop/min! test-client "a" #:count 2)
                   '((#"a" . 1)
                     (#"b" . 2)))
     (check-equal? (redis-zset-pop/min! test-client "a" #:count 2)
                   '((#"c" . 3)))

     (redis-zset-add! test-client "a" "a" 1 "b" 2 "c" 3)
     (check-equal? (redis-zset-pop/max! test-client "a" #:block? #t) (list #"a" #"c" 3))
     (check-equal? (redis-zset-pop/min! test-client "a" #:block? #t) (list #"a" #"a" 1)))))

(module+ test
  (require rackunit/text-ui)
  (run-tests zset-tests))