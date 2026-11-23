"""Small fcntl.flock-compatible adapter for Windows file locks."""
import errno
import msvcrt
import time

LOCK_EX = 1
LOCK_NB = 2


def flock(stream, operation):
    stream.seek(0)
    # Windows allows locking bytes beyond EOF, so empty lock files work too.
    while True:
        try:
            msvcrt.locking(stream.fileno(), msvcrt.LK_NBLCK, 1)
            return
        except OSError as error:
            if error.errno not in (errno.EACCES, errno.EAGAIN):
                raise
            if operation & LOCK_NB:
                raise BlockingIOError(errno.EAGAIN, "lock already held") from None
            time.sleep(0.1)
