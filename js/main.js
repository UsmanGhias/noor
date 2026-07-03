/* Noor ul Haya — Premium interactions */
(function () {
  'use strict';

  if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
    gsap.registerPlugin(ScrollTrigger);
  }

  // ── Nav ──
  const nav = document.getElementById('nav');
  const burger = document.getElementById('navBurger');
  const drawer = document.getElementById('navDrawer');

  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 30);
  }, { passive: true });

  burger?.addEventListener('click', () => drawer.classList.toggle('open'));
  drawer?.querySelectorAll('a').forEach((a) => {
    a.addEventListener('click', () => drawer.classList.remove('open'));
  });

  // ── Cursor glow ──
  const cursor = document.querySelector('.cursor');
  if (cursor && window.matchMedia('(pointer: fine)').matches) {
    document.addEventListener('mousemove', (e) => {
      cursor.style.left = e.clientX + 'px';
      cursor.style.top = e.clientY + 'px';
    }, { passive: true });
  }

  // ── Starfield ──
  const canvas = document.getElementById('stars');
  if (canvas) {
    const ctx = canvas.getContext('2d');
    let stars = [];

    function resize() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      const n = Math.min(120, Math.floor(window.innerWidth / 12));
      stars = Array.from({ length: n }, () => ({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 1.5 + 0.3,
        a: Math.random(),
        sp: Math.random() * 0.015 + 0.005,
      }));
    }

    function draw() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      stars.forEach((s) => {
        s.a += s.sp;
        const opacity = 0.3 + Math.abs(Math.sin(s.a)) * 0.5;
        ctx.beginPath();
        ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(200, 210, 255, ${opacity})`;
        ctx.fill();
      });
      requestAnimationFrame(draw);
    }

    resize();
    draw();
    window.addEventListener('resize', resize, { passive: true });
  }

  // ── Live countdown (demo to Maghrib 7:22 PM) ──
  const countdownEl = document.getElementById('liveCountdown');
  if (countdownEl) {
    function tick() {
      const now = new Date();
      const target = new Date();
      target.setHours(19, 22, 0, 0);
      if (now > target) target.setDate(target.getDate() + 1);
      const diff = target - now;
      const h = Math.floor(diff / 3600000);
      const m = Math.floor((diff % 3600000) / 60000);
      const s = Math.floor((diff % 60000) / 1000);
      countdownEl.textContent =
        String(h).padStart(2, '0') + ':' +
        String(m).padStart(2, '0') + ':' +
        String(s).padStart(2, '0');
    }
    tick();
    setInterval(tick, 1000);
  }

  // ── Scroll reveal ──
  const reveals = document.querySelectorAll('.reveal');
  const obs = new IntersectionObserver((entries) => {
    entries.forEach((e) => {
      if (e.isIntersecting) {
        e.target.classList.add('visible');
        obs.unobserve(e.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -30px 0px' });
  reveals.forEach((el) => obs.observe(el));

  // ── Counter animation ──
  document.querySelectorAll('[data-count]').forEach((el) => {
    const target = parseInt(el.dataset.count, 10);
    const counterObs = new IntersectionObserver((entries) => {
      if (!entries[0].isIntersecting) return;
      const start = performance.now();
      const dur = 2000;
      function step(now) {
        const p = Math.min((now - start) / dur, 1);
        const eased = 1 - Math.pow(1 - p, 4);
        el.textContent = Math.round(eased * target);
        if (p < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
      counterObs.unobserve(el);
    }, { threshold: 0.5 });
    counterObs.observe(el);
  });

  // ── GSAP animations ──
  if (typeof gsap !== 'undefined') {
    const tl = gsap.timeline({ defaults: { ease: 'power3.out' } });
    tl.from('.eyebrow', { y: 20, opacity: 0, duration: 0.6 })
      .from('.hero__title-line', { y: 40, opacity: 0, duration: 0.8, stagger: 0.12 }, '-=0.3')
      .from('.hero__arabic', { y: 20, opacity: 0, duration: 0.6 }, '-=0.4')
      .from('.hero__verse', { y: 20, opacity: 0, duration: 0.5 }, '-=0.3')
      .from('.hero__desc', { y: 20, opacity: 0, duration: 0.6 }, '-=0.2')
      .from('.hero__cta .btn', { y: 20, opacity: 0, duration: 0.5, stagger: 0.1 }, '-=0.2')
      .from('.hero__metrics .metric', { y: 20, opacity: 0, duration: 0.5, stagger: 0.08 }, '-=0.2')
      .from('.device--front', { x: 80, opacity: 0, duration: 1.2, ease: 'power2.out' }, '-=0.8')
      .from('.device--back', { x: 40, opacity: 0, duration: 1, ease: 'power2.out' }, '-=1')
      .from('.float-card', { scale: 0, opacity: 0, duration: 0.5, stagger: 0.12, ease: 'back.out(2)' }, '-=0.5');

    gsap.from('.bento__card', {
      y: 50, opacity: 0, duration: 0.7, stagger: 0.08, ease: 'power2.out',
      scrollTrigger: { trigger: '.bento', start: 'top 80%' },
    });

    gsap.from('.screen-card', {
      x: 60, opacity: 0, duration: 0.6, stagger: 0.1, ease: 'power2.out',
      scrollTrigger: { trigger: '.screens__rail', start: 'top 85%' },
    });

    gsap.from('.dua-card', {
      x: -30, opacity: 0, duration: 0.6, stagger: 0.15, ease: 'power2.out',
      scrollTrigger: { trigger: '.dua-stack', start: 'top 80%' },
    });

    gsap.from('.step', {
      y: 40, opacity: 0, duration: 0.7, stagger: 0.12, ease: 'power2.out',
      scrollTrigger: { trigger: '.journey__steps', start: 'top 80%' },
    });

    gsap.from('.download__panel', {
      y: 60, opacity: 0, duration: 0.9, ease: 'power2.out',
      scrollTrigger: { trigger: '.download__panel', start: 'top 85%' },
    });

    gsap.from('.why__card', {
      y: 40, opacity: 0, duration: 0.6, stagger: 0.1, ease: 'power2.out',
      scrollTrigger: { trigger: '.why__grid', start: 'top 85%' },
    });

    gsap.from('.compare', {
      y: 30, opacity: 0, duration: 0.7, ease: 'power2.out',
      scrollTrigger: { trigger: '.compare', start: 'top 88%' },
    });

    gsap.from('.faq__item', {
      y: 20, opacity: 0, duration: 0.5, stagger: 0.08, ease: 'power2.out',
      scrollTrigger: { trigger: '.faq__list', start: 'top 85%' },
    });

    gsap.from('.tech__detail', {
      scale: 0.9, opacity: 0, duration: 0.4, stagger: 0.08, ease: 'back.out(1.4)',
      scrollTrigger: { trigger: '.tech__details', start: 'top 90%' },
    });

    // Parallax hero mesh
    gsap.to('.hero__mesh', {
      y: -100,
      scrollTrigger: { trigger: '.hero', start: 'top top', end: 'bottom top', scrub: 1 },
    });
  }

  // ── Screens horizontal drag scroll ──
  const rail = document.getElementById('screensRail');
  if (rail) {
    let isDown = false, startX, scrollLeft;
    rail.addEventListener('mousedown', (e) => {
      isDown = true; startX = e.pageX - rail.offsetLeft; scrollLeft = rail.scrollLeft;
      rail.style.cursor = 'grabbing';
    });
    rail.addEventListener('mouseleave', () => { isDown = false; rail.style.cursor = 'grab'; });
    rail.addEventListener('mouseup', () => { isDown = false; rail.style.cursor = 'grab'; });
    rail.addEventListener('mousemove', (e) => {
      if (!isDown) return;
      e.preventDefault();
      const x = e.pageX - rail.offsetLeft;
      rail.scrollLeft = scrollLeft - (x - startX) * 1.5;
    });
    rail.style.cursor = 'grab';
  }

  // ── Smooth anchor scroll ──
  document.querySelectorAll('a[href^="#"]').forEach((a) => {
    a.addEventListener('click', (e) => {
      const id = a.getAttribute('href');
      if (id === '#') return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      const top = target.getBoundingClientRect().top + window.scrollY - 76;
      window.scrollTo({ top, behavior: 'smooth' });
    });
  });

  // ── Magnetic buttons ──
  document.querySelectorAll('.btn--glow').forEach((btn) => {
    btn.addEventListener('mousemove', (e) => {
      const rect = btn.getBoundingClientRect();
      const x = e.clientX - rect.left - rect.width / 2;
      const y = e.clientY - rect.top - rect.height / 2;
      btn.style.transform = `translate(${x * 0.15}px, ${y * 0.15}px)`;
    });
    btn.addEventListener('mouseleave', () => { btn.style.transform = ''; });
  });
})();
