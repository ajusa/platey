import std/locks
export locks

type Lockable*[T] = object
  lock: Lock
  value: T

proc initLockable*[T](value: T): Lockable[T] =
  var lock: Lock
  initLock(lock)
  return Lockable[T](lock: lock, value: value)

template hold*(lockable: Lockable, body: untyped) = {.gcsafe.}: 
  withLock lockable.lock: body

template makeCopy*[T](lockable: var Lockable[T]): untyped =
  var tmp: typeof lockable.value
  hold(lockable): tmp = lockable.value
  tmp
