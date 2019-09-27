## Ways to correctly increment an attribute with concurrency

- **SimpleProduct** gives wrong results for concurrent situations, as explained above.
- **OptimisticProduct** has some problems to scale with multiple threads. This makes sense as there is retry involved when concurrent updates occur.
- **DbCheckProduct** is the fastest implementation which seems reasonable as there is no locking involved
- **PessimisticProduct** can profit as well in a concurrent setup

Reference [link](https://blog.simplificator.com/2015/01/23/incrementdecrement-counters-in-activerecord/)
