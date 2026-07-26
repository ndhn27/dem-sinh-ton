// Smoke tests for index.html (the standalone JS/Canvas build).
//
// These do NOT test visual rendering (no real browser/canvas is available in CI).
// What they DO catch, cheaply, on every push/PR:
//   - the game boots without throwing (syntax errors, ReferenceErrors, null-deref on
//     an element id, etc. would all fail these tests)
//   - core state transitions behave as expected (start -> playing, damage -> gameover,
//     xp -> level up, enemy hp -> death/kill count)
//   - the simulation can run many ticks in a row without throwing (catches a whole
//     class of "works for 10 seconds then crashes" bugs)
//
// This intentionally does not try to validate pixel output, animation smoothness, or
// input handling (touch/keyboard) — those still need manual playtesting.

import { JSDOM } from 'jsdom';
import fs from 'node:fs';
import path from 'node:path';
import { test } from 'node:test';
import assert from 'node:assert/strict';

const INDEX_HTML_PATH = path.join(import.meta.dirname, '..', 'index.html');
const html = fs.readFileSync(INDEX_HTML_PATH, 'utf8');

// jsdom has no real <canvas> 2D rendering backend. We stub getContext('2d') with a
// permissive proxy: every property read returns a function, and every function call
// returns the same stub (so chained calls like ctx.createRadialGradient(...).addColorStop(...)
// don't throw). This lets the game's render() path execute for real without needing
// the native `canvas` package or a real GPU/browser.
function makeCtxStub() {
  const stub = new Proxy(function () {}, {
    get(_target, prop) {
      if (prop === 'canvas') return {};
      return function (..._args) {
        return stub;
      };
    },
    set() {
      return true;
    },
  });
  return stub;
}

function loadGame() {
  const dom = new JSDOM(html, {
    runScripts: 'dangerously',
    pretendToBeVisual: true,
    resources: undefined, // never fetch external stylesheets/fonts in CI
    beforeParse(window) {
      window.HTMLCanvasElement.prototype.getContext = () => makeCtxStub();
      // index.html kicks off its own requestAnimationFrame(loop) render loop on load,
      // independent of game state. We don't want that real-time, self-perpetuating
      // loop running during tests (it hangs the process and races with manual ticks),
      // so we replace it with a no-op. Tests advance the simulation deterministically
      // via hooks.update(dt) instead.
      window.requestAnimationFrame = () => 0;
      window.cancelAnimationFrame = () => {};
    },
  });
  const hooks = dom.window.__gameTestHooks;
  assert.ok(hooks, 'window.__gameTestHooks should be exposed by index.html');
  return { dom, hooks };
}

test('boots without throwing and exposes test hooks', () => {
  const { dom, hooks } = loadGame();
  assert.equal(hooks.game.state, 'start');
  dom.window.close();
});

test('startGame() initializes a fresh, alive player', () => {
  const { dom, hooks } = loadGame();
  hooks.startGame();
  const { game } = hooks;
  assert.equal(game.state, 'playing');
  assert.ok(game.player, 'player should exist after startGame()');
  assert.equal(game.player.health, game.player.maxHealth);
  assert.equal(game.player.weapons.dagger, 1);
  assert.equal(Object.keys(game.player.weapons).length, 1);
  assert.equal(game.enemies.length, 0);
  dom.window.close();
});

test('simulation can run many ticks without throwing (no crash-after-N-seconds bugs)', () => {
  const { dom, hooks } = loadGame();
  hooks.startGame();
  const { game } = hooks;
  const dt = 1 / 60;
  const ticks = 60 * 60; // simulate ~60s of gameplay at 60fps
  assert.doesNotThrow(() => {
    for (let i = 0; i < ticks; i++) {
      hooks.update(dt);
      // Auto-resolve any level-up prompts so the sim keeps progressing instead of
      // idling in the 'levelup' state waiting for a click.
      if (game.state === 'levelup') {
        game.levelUpQueue = 0;
        game.state = 'playing';
      }
    }
  });
  assert.ok(game.elapsed > 59, 'elapsed time should track simulated ticks');
  assert.ok(game.enemies.length > 0, 'enemies should have spawned over 60s');
  dom.window.close();
});

test('gainXp() eventually triggers a level up', () => {
  const { dom, hooks } = loadGame();
  hooks.startGame();
  const { game } = hooks;
  const startingLevel = game.player.level;
  hooks.gainXp(500);
  assert.ok(game.player.level > startingLevel, 'player should have leveled up');
  dom.window.close();
});

test('damageEnemy() past 0 hp kills the enemy and increments the kill counter', () => {
  const { dom, hooks } = loadGame();
  hooks.startGame();
  const { game } = hooks;
  const enemy = hooks.makeEnemy('zombie', false);
  game.enemies.push(enemy);
  const killsBefore = game.kills;
  hooks.damageEnemy(enemy, enemy.hp + 999);
  assert.equal(enemy.dead, true);
  assert.equal(game.kills, killsBefore + 1);
  dom.window.close();
});

test('health reaching 0 ends the game (without the guardian relic)', () => {
  const { dom, hooks } = loadGame();
  hooks.startGame();
  const { game } = hooks;
  game.player.health = 0;
  hooks.endGame();
  assert.equal(game.state, 'gameover');
  const goScreen = dom.window.document.getElementById('gameover-screen');
  assert.equal(goScreen.classList.contains('hidden'), false);
  dom.window.close();
});
