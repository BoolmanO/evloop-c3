module evloop::async;
import evloop::coroutine;

struct Async {
  CoroutineStatus status;
  CoroutineCtx ctx;
}
