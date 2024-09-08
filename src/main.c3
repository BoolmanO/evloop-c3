module main;
import std::io;
import std::collections::list;
import evloop;

fn Async coro(CoroutineCtx this) {
  switch (this.step) {
    case 0:
      int* value = malloc(int.sizeof);
      *value = 69;
      return this.next(value);
    case 1:
      int x = *(int*)this.out;
      defer free(this.out);
      int* result = malloc(int.sizeof);
      *result = x + 69;
      io::printn("Hello from another async function!!!!");
      io::printn(*result);
      return this.final(result);
    default:
      unreachable();
  }
}

fn Async coro_2(CoroutineCtx this) {
  switch (this.step) {
    case 0:
      int* value = malloc(int.sizeof);
      *value = 69;
      io::printn("Hello from coro_2 case 0");
      return this.next(value);
    case 1:
      int x = *(int*)this.out;
      defer free(this.out);
      int y = *(int*)this.await(&coro, null);
      int* result = malloc(int.sizeof);
      *result = x + 69 + y;
      io::printn("Hello from coro_2 case 1");
      io::printn(*result);
      return this.final();
    default:
      unreachable();
  }
}

fn Async coro_3(CoroutineCtx this) {
  switch (this.step) {
    case 0:
      io::printn("Coro_3!");
      return this.final(null);
    default:
      unreachable();
  }
}

fn int main(String[] args)
{
  EvLoop evloop = evloop::loop::new();
  evloop.add_coroutine(&coro_3, null);
  evloop.add_coroutine(&coro_2, null);
  evloop.loop_progress();
	return 0;
}
