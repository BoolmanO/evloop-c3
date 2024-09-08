module evloop::coroutine;
import evloop::loop;
import evloop::async;

enum CoroutineStatus : int {
  PENDING,
  RUNNING,
  TERMINATED,
  FINISHED,
}

def Coroutine = fn Async(CoroutineCtx this);

struct CoroutineCtx {
  Coroutine coroutine;
  uint step;
  void* out;
  EvLoop* evloop;
}

fn Async CoroutineCtx.next(CoroutineCtx this, void* data = null) {
  this.step = this.step + 1;
  this.out = data;
  return Async {CoroutineStatus.RUNNING, this};
}

fn Async CoroutineCtx.final(CoroutineCtx this, void* data = null) {
  this.out = data;
  return Async {CoroutineStatus.FINISHED, this};
}

fn void* CoroutineCtx.await(CoroutineCtx this, Coroutine coro, void* args) {
  return this.evloop.run(coro, args);
}
