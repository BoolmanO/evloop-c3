module evloop::async;
import evloop::coroutine;

struct Async {
  CoroutineStatus status;
  CoroutineCtx ctx;
}

fn bool Async.is_active(&self) {
  return (self.status != FINISHED && self.status != TERMINATED);
}
