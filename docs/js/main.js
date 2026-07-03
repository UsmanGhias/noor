/* Noor ul Haya — Showcase interactions & animations */

(function () {
  'use strict';

  // ---- GSAP setup ----
  if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
    gsap.registerPlugin(ScrollTrigger);
  }

  // ---- Nav scroll effect ----
  const nav = document.getElementById('nav');
  const navToggle = document.getElementById('navToggle');
  const navMobile = document.getElementById('navMobile');

  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 40);
  }, { passive: true });

  navToggle?.addEventListener('click', () => {
    const open = navMobile.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', String(open));
  });

  navMobile?.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', () => navMobile.classList.remove('open'));
  });

  // ---- Cursor glow ----
  const glow = document.querySelector('.cursor-glow');
  if (glow && window.matchMedia('(pointer: fine)').matches) {
    document.addEventListener('mousemove', (e) => {
      glow.style.left = e.clientX + 'px';
      glow.style.top = e.clientY + 'px';
    }, { passive: true });
  }

  // ---- Particle canvas ----
  const canvas = document.getElementById('particles');
  if (canvas) {
    const ctx = canvas.getContext('2d');
    let particles = [];
    let animId;

    function resize() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }

    function createParticles() {
      const count = Math.min(60, Math.floor(window.innerWidth / 20));
      particles = Array.from({ length: count }, () => ({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 2 + 0.5,
        dx: (Math.random() - 0.5) * 0.4,
        dy: (Math.random() - 0.5) * 0.4,
        opacity: Math.random() * 0.4 + 0.1,
      }));
    }

    function drawParticles() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      particles.forEach((p) => {
        p.x += p.dx;
        p.y += p.dy;
        if (p.x < 0) p.x = canvas.width;
        if (p.x > canvas.width) p.x = 0;
        if (p.y < 0) p.y = canvas.height;
        if (p.y > canvas.height) p.y = 0;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(107, 78, 255, ${p.opacity})`;
        ctx.fill();
      });

      // Connect nearby particles
      for (let i = 0; i < particles.length; i++) {
        for (let j = i + 1; j < particles.length; j++) {
          const dx = particles[i].x - particles[j].x;
          const dy = particles[i].y - particles[j].y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist < 120) {
            ctx.beginPath();
            ctx.moveTo(particles[i].x, particles[i].y);
            ctx.lineTo(particles[j].x, particles[j].y);
            ctx.strokeStyle = `rgba(107, 78, 255, ${0.06 * (1 - dist / 120)})`;
            ctx.lineWidth = 0.5;
            ctx.stroke();
          }
        }
      }

      animId = requestAnimationFrame(drawParticles);
    }

    resize();
    createParticles();
    drawParticles();

    window.addEventListener('resize', () => {
      resize();
      createParticles();
    }, { passive: true });
  }

  // ---- Scroll reveal ----
  const revealEls = document.querySelectorAll('.reveal, .reveal-left, .reveal-right');
  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const delay = entry.target.dataset.delay
            ? parseInt(entry.target.dataset.delay, 10) * 100
            : 0;
          setTimeout(() => entry.target.classList.add('visible'), delay);
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
  );
  revealEls.forEach((el) => revealObserver.observe(el));

  // ---- Counter animation ----
  const counters = document.querySelectorAll('[data-count]');
  const counterObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const el = entry.target;
        const target = parseInt(el.dataset.count, 10);
        const duration = 1800;
        const start = performance.now();

        function tick(now) {
          const progress = Math.min((now - start) / duration, 1);
          const eased = 1 - Math.pow(1 - progress, 3);
          el.textContent = Math.round(eased * target);
          if (progress < 1) requestAnimationFrame(tick);
        }

        requestAnimationFrame(tick);
        counterObserver.unobserve(el);
      });
    },
    { threshold: 0.5 }
  );
  counters.forEach((c) => counterObserver.observe(c));

  // ---- Showcase tabs ----
  const tabs = document.querySelectorAll('.showcase-tab');
  const panels = document.querySelectorAll('.screen-panel');

  tabs.forEach((tab) => {
    tab.addEventListener('click', () => {
      const id = tab.dataset.tab;
      tabs.forEach((t) => t.classList.remove('active'));
      tab.classList.add('active');

      panels.forEach((panel) => {
        panel.classList.toggle('active', panel.dataset.panel === id);
      });

      // GSAP phone shake
      if (typeof gsap !== 'undefined') {
        gsap.fromTo('#showcaseScreen',
          { scale: 0.97, opacity: 0.7 },
          { scale: 1, opacity: 1, duration: 0.4, ease: 'back.out(1.4)' }
        );
      }
    });
  });

  // ---- Tasbih tap in showcase ----
  const tasbihRing = document.querySelector('.sp-tasbih__ring');
  const tasbihCount = document.querySelector('.sp-tasbih__count');
  if (tasbihRing && tasbihCount) {
    let count = 33;
    tasbihRing.addEventListener('click', () => {
      count++;
      tasbihCount.textContent = count;
      if (typeof gsap !== 'undefined') {
        gsap.fromTo(tasbihCount,
          { scale: 1.3 },
          { scale: 1, duration: 0.3, ease: 'back.out(2)' }
        );
      }
    });
  }

  // ---- GSAP hero animations ----
  if (typeof gsap !== 'undefined') {
    const tl = gsap.timeline({ defaults: { ease: 'power3.out' } });

    tl.from('.hero__badge', { y: 20, opacity: 0, duration: 0.6 })
      .from('.hero__title', { y: 30, opacity: 0, duration: 0.7 }, '-=0.3')
      .from('.hero__arabic', { y: 20, opacity: 0, duration: 0.5 }, '-=0.3')
      .from('.hero__subtitle', { y: 20, opacity: 0, duration: 0.6 }, '-=0.2')
      .from('.hero__actions', { y: 20, opacity: 0, duration: 0.5 }, '-=0.2')
      .from('.hero__stats', { y: 20, opacity: 0, duration: 0.5 }, '-=0.2')
      .from('.hero__phone', { x: 60, opacity: 0, duration: 1, ease: 'power2.out' }, '-=0.8')
      .from('.hero__float', { scale: 0, opacity: 0, duration: 0.5, stagger: 0.15, ease: 'back.out(2)' }, '-=0.5');

    // Parallax orbs
    gsap.to('.hero__orb--1', {
      y: -80,
      scrollTrigger: { trigger: '.hero', start: 'top top', end: 'bottom top', scrub: 1 },
    });
    gsap.to('.hero__orb--2', {
      y: -120,
      scrollTrigger: { trigger: '.hero', start: 'top top', end: 'bottom top', scrub: 1 },
    });

    // Feature cards stagger
    gsap.from('.feature-card', {
      y: 40,
      opacity: 0,
      duration: 0.6,
      stagger: 0.08,
      ease: 'power2.out',
      scrollTrigger: {
        trigger: '.features__grid',
        start: 'top 80%',
      },
    });

    // How steps
    gsap.from('.how-step', {
      y: 50,
      opacity: 0,
      duration: 0.7,
      stagger: 0.2,
      ease: 'power2.out',
      scrollTrigger: {
        trigger: '.how__steps',
        start: 'top 80%',
      },
    });

    // Download card
    gsap.from('.download__card', {
      y: 60,
      opacity: 0,
      duration: 0.8,
      ease: 'power2.out',
      scrollTrigger: {
        trigger: '.download__card',
        start: 'top 85%',
      },
    });

    // Tech pills wave
    gsap.from('.tech-pill', {
      scale: 0.8,
      opacity: 0,
      duration: 0.4,
      stagger: 0.05,
      ease: 'back.out(1.5)',
      scrollTrigger: {
        trigger: '.tech__grid',
        start: 'top 85%',
      },
    });
  }

  // ---- Smooth anchor scroll offset for fixed nav ----
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener('click', (e) => {
      const id = anchor.getAttribute('href');
      if (id === '#') return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      const offset = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--nav-height'), 10) || 72;
      const top = target.getBoundingClientRect().top + window.scrollY - offset;
      window.scrollTo({ top, behavior: 'smooth' });
    });
  });

  // ---- Auto-cycle showcase tabs (optional) ----
  let autoTabIndex = 0;
  const tabIds = ['prayer', 'qibla', 'quran', 'duas', 'tasbih', 'settings'];
  let autoTabInterval;

  function startAutoTabs() {
    autoTabInterval = setInterval(() => {
      const showcase = document.getElementById('showcase');
      if (!showcase) return;
      const rect = showcase.getBoundingClientRect();
      if (rect.top > window.innerHeight || rect.bottom < 0) return;

      autoTabIndex = (autoTabIndex + 1) % tabIds.length;
      const tab = document.querySelector(`.showcase-tab[data-tab="${tabIds[autoTabIndex]}"]`);
      tab?.click();
    }, 5000);
  }

  // Only auto-cycle when showcase is visible
  const showcaseSection = document.getElementById('showcase');
  if (showcaseSection) {
    const showcaseObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            startAutoTabs();
          } else {
            clearInterval(autoTabInterval);
          }
        });
      },
      { threshold: 0.3 }
    );
    showcaseObserver.observe(showcaseSection);

    // Pause auto-cycle on manual tab click
    tabs.forEach((tab) => {
      tab.addEventListener('click', () => {
        clearInterval(autoTabInterval);
        autoTabIndex = tabIds.indexOf(tab.dataset.tab);
        setTimeout(startAutoTabs, 12000);
      });
    });
  }
})();
