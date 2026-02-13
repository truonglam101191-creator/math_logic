import 'dart:math';
import '../data/data.dart';

/// Simple 2D Vector class
class Vec2 {
  double x;
  double y;

  Vec2(this.x, this.y);

  factory Vec2.zero() => Vec2(0, 0);

  Vec2 operator +(Vec2 other) => Vec2(x + other.x, y + other.y);
  Vec2 operator -(Vec2 other) => Vec2(x - other.x, y - other.y);
  Vec2 operator *(double scalar) => Vec2(x * scalar, y * scalar);

  double get length => sqrt(x * x + y * y);
  double get lengthSquared => x * x + y * y;

  Vec2 normalized() {
    final len = length;
    if (len == 0) return Vec2(0, 0);
    return Vec2(x / len, y / len);
  }

  double dot(Vec2 other) => x * other.x + y * other.y;

  static double distance(Vec2 a, Vec2 b) => (a - b).length;

  Vec2 clone() => Vec2(x, y);

  @override
  String toString() => 'Vec2($x, $y)';
}

/// Simple physics body for circles
class PhysicsBody {
  String id;
  Vec2 position;
  Vec2 velocity;
  double radius;
  double mass;
  double angle;
  double angularVelocity;
  bool isStatic;
  Object? userData;
  // Time of last collision/contact (seconds) to prevent repeated tiny impulses
  double lastContactTime = -9999.0;

  PhysicsBody({
    required this.id,
    required this.position,
    required this.radius,
    this.mass = 1.0,
    Vec2? velocity,
    this.angle = 0,
    this.angularVelocity = 0,
    this.isStatic = false,
    this.userData,
  }) : velocity = velocity ?? Vec2.zero();

  void update(double dt) {
    if (isStatic) return;
    position = position + velocity * dt;
    angle += angularVelocity * dt;

    // Normalize angle to [-PI, PI]
    while (angle > pi) {
      angle -= 2 * pi;
    }
    while (angle < -pi) {
      angle += 2 * pi;
    }
  }
}

/// Simple collision info
class CollisionInfo {
  final PhysicsBody bodyA;
  final PhysicsBody bodyB;
  final Vec2 contactPoint;
  final double penetration;

  CollisionInfo({
    required this.bodyA,
    required this.bodyB,
    required this.contactPoint,
    required this.penetration,
  });
}

/// Simple physics world for the game
class PhysicsController {
  final List<PhysicsBody> _bodies = [];

  double gravity = GameConstants.gravity * 60;
  double gravityMultiplier = 1.5;
  double slideDistanceRatio = 0.5;
  bool enforceCenterDrop = true;
  double friction = GameConstants.friction;
  double restitution = GameConstants.restitution;

  // Timing and contact tuning
  double _time = 0.0;
  double contactCooldown = 0.06; // seconds between contact spin impulses
  double smallImpactThreshold = 20.0; // treat below this as "slow" collision

  // Simplified physics constants
  static const double linearDamping = .99; // stronger damping to settle faster
  static const double angularDamping = 0.8; // damp rotation quicker
  static const double maxAngularVelocity = 2;
  static const double velocityRestThreshold = 20.0;

  PhysicsController();

  /// Add a circular body
  PhysicsBody createBody({
    required double x,
    required double y,
    required double radius,
    required int typeIndex,
    Object? userData,
  }) {
    final body = PhysicsBody(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_bodies.length}',
      position: Vec2(x, y),
      radius: radius,
      mass: 1.0 + typeIndex * 0.5,
      userData: userData,
    );
    _bodies.add(body);
    return body;
  }

  /// Remove a body
  void removeBody(PhysicsBody body) {
    _bodies.remove(body);
  }

  /// Step simulation
  void step(double dt) {
    // Clamp dt to avoid instability with large time steps
    dt = dt.clamp(0.001, 0.033);

    // advance world time
    _time += dt;

    // Apply gravity
    for (final body in _bodies) {
      if (!body.isStatic) {
        body.velocity.y += gravity * gravityMultiplier * dt;

        if (enforceCenterDrop && body.velocity.y > 0) {
          final centerX =
              (GameConstants.containerLeft + GameConstants.containerRight) / 2;
          final dx = centerX - body.position.x;
          // Pull horizontally toward center while damping stray horizontal speed
          body.velocity.x = body.velocity.x * 0.7 + dx * 0.02;
        }
      }
    }

    // Update positions
    for (final body in _bodies) {
      body.update(dt);
    }

    // Apply damping
    for (final body in _bodies) {
      if (body.isStatic) continue;

      body.velocity = body.velocity * linearDamping;
      body.angularVelocity *= angularDamping;

      // Clamp angular velocity
      body.angularVelocity = body.angularVelocity.clamp(
        -maxAngularVelocity,
        maxAngularVelocity,
      );

      // Stop if very slow
      if (body.velocity.lengthSquared < 1) {
        body.velocity = Vec2.zero();
      }
      if (body.angularVelocity.abs() < 0.01) {
        body.angularVelocity = 0;
      }
    }

    // Resolve collisions - multiple iterations for stability
    for (int i = 0; i < 5; i++) {
      _resolveWallCollisions();
      _resolveBodyCollisions();
    }
  }

  void _resolveWallCollisions() {
    final left = GameConstants.containerLeft;
    final right = GameConstants.containerRight;
    final bottom = GameConstants.containerBottom;

    for (final body in _bodies) {
      if (body.isStatic) continue;

      // Floor collision
      if (body.position.y + body.radius > bottom) {
        body.position.y = bottom - body.radius;

        if (body.velocity.y > 0) {
          // Only bounce if moving downward
          if (body.velocity.y > velocityRestThreshold) {
            body.velocity.y = -body.velocity.y * restitution;
            // Small rotation on impact
            body.angularVelocity += body.velocity.x * 0.002;
          } else {
            // Settle - stop vertical movement
            body.velocity.y = 0;
            body.angularVelocity *= 0.6; // reduce spin quicker on settle

            // Inject a very small slide along the floor for unmerged contacts
            final width = right - left;
            final slideDistance = width * slideDistanceRatio;
            final centerX = (left + right) / 2;
            double dir = body.velocity.x.abs() > 0.01
                ? body.velocity.x.sign
                : (body.position.x >= centerX ? 1 : -1);
            // keep it small to avoid pushing other objects continuously
            body.velocity.x = dir * slideDistance * 0.1;
          }
        }
      }

      // Left wall collision
      if (body.position.x - body.radius < left) {
        body.position.x = left + body.radius;
        if (body.velocity.x < 0) {
          body.velocity.x = -body.velocity.x * restitution;
        }
      }

      // Right wall collision
      if (body.position.x + body.radius > right) {
        body.position.x = right - body.radius;
        if (body.velocity.x > 0) {
          body.velocity.x = -body.velocity.x * restitution;
        }
      }
    }
  }

  void _resolveBodyCollisions() {
    for (var i = 0; i < _bodies.length; i++) {
      for (var j = i + 1; j < _bodies.length; j++) {
        final a = _bodies[i];
        final b = _bodies[j];

        final dx = b.position.x - a.position.x;
        final dy = b.position.y - a.position.y;
        final dist = sqrt(dx * dx + dy * dy);
        final minDist = a.radius + b.radius;

        if (dist < minDist && dist > 0.001) {
          // Collision detected - separate bodies
          final overlap = minDist - dist;
          final nx = dx / dist; // Normal x
          final ny = dy / dist; // Normal y

          // Position correction - push apart completely
          final totalMass = a.mass + b.mass;
          final aRatio = b.mass / totalMass;
          final bRatio = a.mass / totalMass;

          // Positional correction: push apart just enough (avoid large overshoot)
          final correction = overlap * 1.01; // small bias to remove penetration
          a.position.x -= nx * correction * aRatio;
          a.position.y -= ny * correction * aRatio;
          b.position.x += nx * correction * bRatio;
          b.position.y += ny * correction * bRatio;

          // Calculate relative velocity
          final dvx = a.velocity.x - b.velocity.x;
          final dvy = a.velocity.y - b.velocity.y;
          final dvn = dvx * nx + dvy * ny; // Relative velocity along normal

          // Only apply impulse if approaching
          if (dvn < 0) {
            // Calculate impulse
            final e = restitution;
            final j = -(1 + e) * dvn / (1 / a.mass + 1 / b.mass);

            // Apply impulse
            a.velocity.x += j * nx / a.mass;
            a.velocity.y += j * ny / a.mass;
            b.velocity.x -= j * nx / b.mass;
            b.velocity.y -= j * ny / b.mass;

            // Apply friction (tangent impulse)
            final tx = -ny;
            final ty = nx;
            final dvt = dvx * tx + dvy * ty;
            final jt = -dvt * friction * 0.3 / (1 / a.mass + 1 / b.mass);

            a.velocity.x += jt * tx / a.mass;
            a.velocity.y += jt * ty / a.mass;
            b.velocity.x -= jt * tx / b.mass;
            b.velocity.y -= jt * ty / b.mass;

            // Small rotation from collision: give a brief spin proportional to tangential
            final spin = (dvt * 0.005) / (1 + (a.radius + b.radius) / 2);
            // clamp spin to avoid runaway
            final clampedSpin = spin.clamp(-0.9, 0.9);

            // Throttle repeated tiny impulses using per-body contact timers
            final canA = (_time - a.lastContactTime) > contactCooldown;
            final canB = (_time - b.lastContactTime) > contactCooldown;

            if (canA && canB) {
              // If impact is slow, give a slightly larger brief spin then damp linear velocity
              final impactSpeed = sqrt(dvx * dvx + dvy * dvy);
              final spinScale = impactSpeed < smallImpactThreshold ? 1.6 : 1.0;
              final appliedSpin = (clampedSpin * spinScale).clamp(-1.2, 1.2);

              a.angularVelocity += appliedSpin;
              b.angularVelocity -= appliedSpin;

              // record contact time to avoid reapplying within the same frame/iterations
              a.lastContactTime = _time;
              b.lastContactTime = _time;

              // For very small impacts, kill most linear motion so objects rotate then settle
              if (impactSpeed < smallImpactThreshold) {
                a.velocity = a.velocity * 0.12;
                b.velocity = b.velocity * 0.12;
                if (a.velocity.length < 6.0) a.velocity = Vec2.zero();
                if (b.velocity.length < 6.0) b.velocity = Vec2.zero();
              }
            }
          }
        }
      }
    }
  }

  /// Get all colliding pairs for merge detection
  List<CollisionInfo> getCollisions() {
    final collisions = <CollisionInfo>[];

    for (var i = 0; i < _bodies.length; i++) {
      for (var j = i + 1; j < _bodies.length; j++) {
        final a = _bodies[i];
        final b = _bodies[j];

        final dist = Vec2.distance(a.position, b.position);
        final minDist = a.radius + b.radius;

        if (dist < minDist * 1.02) {
          final contactPoint = Vec2(
            (a.position.x + b.position.x) / 2,
            (a.position.y + b.position.y) / 2,
          );

          collisions.add(
            CollisionInfo(
              bodyA: a,
              bodyB: b,
              contactPoint: contactPoint,
              penetration: minDist - dist,
            ),
          );
        }
      }
    }

    return collisions;
  }

  /// Get all bodies
  List<PhysicsBody> get bodies => List.unmodifiable(_bodies);

  /// Reset physics world
  void reset() {
    _bodies.clear();
  }

  void dispose() {
    _bodies.clear();
  }

  void setDropSpeedMultiplier(double multiplier) {
    gravityMultiplier = multiplier.clamp(0.1, 5.0);
  }

  void setPostDropSlideRatio(double ratio) {
    slideDistanceRatio = ratio.clamp(0.0, 1.0);
  }

  void setEnforceCenterDrop(bool value) {
    enforceCenterDrop = value;
  }
}
