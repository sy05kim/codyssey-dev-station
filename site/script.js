(() => {
  const runtime = document.querySelector('#runtime');
  if (!runtime) return;

  const updateClock = () => {
    const now = new Date();
    runtime.textContent = `STATIC / NGINX / ${now.toLocaleTimeString('ko-KR', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })}`;
  };

  updateClock();
  window.setInterval(updateClock, 1000);
})();
