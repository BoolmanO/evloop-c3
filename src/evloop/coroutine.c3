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

fn Async CoroutineCtx.next(self, void* data = null) {
  self.step = self.step + 1;
  self.out = data;
  return {CoroutineStatus.RUNNING, self};
}

fn Async CoroutineCtx.final(self, void* data = null) {
  self.out = data;
  return {CoroutineStatus.FINISHED, self};
}

fn void* CoroutineCtx.await(&self, Coroutine coro, void* args) {
  return self.evloop.run(coro, args);
}
