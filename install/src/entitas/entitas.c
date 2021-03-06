/* entitas.c generated by valac 0.34.8, the Vala compiler
 * generated from entitas.vala, do not modify */


#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>
#include <SDL2/SDL_rect.h>
#include <float.h>
#include <math.h>


#define ENTITAS_TYPE_ENTITY (entitas_entity_get_type ())

#define ENTITAS_TYPE_BACKGROUND (entitas_background_get_type ())
typedef struct _entitasBackground entitasBackground;

#define ENTITAS_TYPE_BULLET (entitas_bullet_get_type ())
typedef struct _entitasBullet entitasBullet;

#define ENTITAS_TYPE_ENEMY1 (entitas_enemy1_get_type ())
typedef struct _entitasEnemy1 entitasEnemy1;

#define ENTITAS_TYPE_ENEMY2 (entitas_enemy2_get_type ())
typedef struct _entitasEnemy2 entitasEnemy2;

#define ENTITAS_TYPE_ENEMY3 (entitas_enemy3_get_type ())
typedef struct _entitasEnemy3 entitasEnemy3;

#define ENTITAS_TYPE_EXPIRES (entitas_expires_get_type ())
typedef struct _entitasExpires entitasExpires;

#define ENTITAS_TYPE_HEALTH (entitas_health_get_type ())
typedef struct _entitasHealth entitasHealth;

#define ENTITAS_TYPE_HUD (entitas_hud_get_type ())
typedef struct _entitasHud entitasHud;

#define ENTITAS_TYPE_INDEX (entitas_index_get_type ())
typedef struct _entitasIndex entitasIndex;

#define ENTITAS_TYPE_LAYER (entitas_layer_get_type ())
typedef struct _entitasLayer entitasLayer;

#define ENTITAS_TYPE_POSITION (entitas_position_get_type ())
typedef struct _entitasPosition entitasPosition;

#define ENTITAS_TYPE_SCALE (entitas_scale_get_type ())
typedef struct _entitasScale entitasScale;

#define ENTITAS_TYPE_SPRITE (entitas_sprite_get_type ())

#define SDX_GRAPHICS_TYPE_SPRITE (sdx_graphics_sprite_get_type ())
#define SDX_GRAPHICS_SPRITE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), SDX_GRAPHICS_TYPE_SPRITE, sdxgraphicsSprite))
#define SDX_GRAPHICS_SPRITE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), SDX_GRAPHICS_TYPE_SPRITE, sdxgraphicsSpriteClass))
#define SDX_GRAPHICS_IS_SPRITE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), SDX_GRAPHICS_TYPE_SPRITE))
#define SDX_GRAPHICS_IS_SPRITE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), SDX_GRAPHICS_TYPE_SPRITE))
#define SDX_GRAPHICS_SPRITE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), SDX_GRAPHICS_TYPE_SPRITE, sdxgraphicsSpriteClass))

typedef struct _sdxgraphicsSprite sdxgraphicsSprite;
typedef struct _sdxgraphicsSpriteClass sdxgraphicsSpriteClass;
typedef struct _entitasSprite entitasSprite;

#define ENTITAS_TYPE_TEXT (entitas_text_get_type ())
typedef struct _entitasText entitasText;

#define ENTITAS_TYPE_TINT (entitas_tint_get_type ())
typedef struct _entitasTint entitasTint;

#define ENTITAS_TYPE_TWEEN (entitas_tween_get_type ())
typedef struct _entitasTween entitasTween;

#define ENTITAS_TYPE_VELOCITY (entitas_velocity_get_type ())
typedef struct _entitasVelocity entitasVelocity;
typedef struct _entitasEntity entitasEntity;

#define ENTITAS_TYPE_BUFFER (entitas_buffer_get_type ())
typedef struct _entitasBuffer entitasBuffer;

#define ENTITAS_TYPE_ISYSTEM (entitas_isystem_get_type ())
typedef struct _entitasISystem entitasISystem;

typedef enum  {
	ENTITAS_EXCEPTION_EntityIsNotEnabled,
	ENTITAS_EXCEPTION_EntityAlreadyHasComponent,
	ENTITAS_EXCEPTION_EntityDoesNotHaveComponent,
	ENTITAS_EXCEPTION_InvalidMatcherExpression,
	ENTITAS_EXCEPTION_EntityIsAlreadyReleased,
	ENTITAS_EXCEPTION_SingleEntity,
	ENTITAS_EXCEPTION_WorldDoesNotContainEntity
} entitasException;
#define ENTITAS_EXCEPTION entitas_exception_quark ()
struct _entitasBackground {
	gboolean active;
};

struct _entitasBullet {
	gboolean active;
};

struct _entitasEnemy1 {
	gboolean active;
};

struct _entitasEnemy2 {
	gboolean active;
};

struct _entitasEnemy3 {
	gboolean active;
};

struct _entitasExpires {
	gdouble value;
};

struct _entitasHealth {
	gdouble current;
	gdouble maximum;
};

struct _entitasHud {
	gboolean active;
};

struct _entitasIndex {
	gint value;
	gint limit;
	gboolean vertical;
};

struct _entitasLayer {
	gint value;
};

struct _entitasPosition {
	gdouble x;
	gdouble y;
};

struct _entitasScale {
	gdouble x;
	gdouble y;
};

struct _entitasSprite {
	sdxgraphicsSprite* sprite;
	gint width;
	gint height;
};

struct _entitasText {
	gchar* text;
	sdxgraphicsSprite* sprite;
};

struct _entitasTint {
	gint r;
	gint g;
	gint b;
	gint a;
};

struct _entitasTween {
	gdouble min;
	gdouble max;
	gdouble speed;
	gboolean repeat;
	gboolean active;
};

struct _entitasVelocity {
	gdouble x;
	gdouble y;
};

struct _entitasEntity {
	gint id;
	gchar* name;
	gint pool;
	guint64 mask;
	entitasBackground* background;
	SDL_Rect* bounds;
	entitasBullet* bullet;
	entitasEnemy1* enemy1;
	entitasEnemy2* enemy2;
	entitasEnemy3* enemy3;
	entitasExpires* expires;
	entitasHealth* health;
	entitasHud* hud;
	entitasIndex* index;
	entitasLayer* layer;
	entitasPosition* position;
	entitasScale* scale;
	entitasSprite* sprite;
	entitasText* text;
	entitasTint* tint;
	entitasTween* tween;
	entitasVelocity* velocity;
};

typedef entitasEntity* (*entitasEntityRemovedListener) (entitasEntity* e, void* user_data);
typedef entitasEntity* (*entitasEntityAddedListener) (entitasEntity* e, void* user_data);
typedef entitasEntity* (*entitasFactory) (void* user_data);
struct _entitasBuffer {
	gint pool;
	gint size;
	entitasFactory factory;
	gpointer factory_target;
	GDestroyNotify factory_target_destroy_notify;
};

typedef void (*entitasSystemInitialize) (void* user_data);
typedef void (*entitasSystemExecute) (gdouble delta, void* user_data);
struct _entitasISystem {
	entitasSystemInitialize initialize;
	gpointer initialize_target;
	entitasSystemExecute execute;
	gpointer execute_target;
};



GQuark entitas_exception_quark (void);
GType entitas_entity_get_type (void) G_GNUC_CONST;
GType entitas_background_get_type (void) G_GNUC_CONST;
entitasBackground* entitas_background_dup (const entitasBackground* self);
void entitas_background_free (entitasBackground* self);
GType entitas_bullet_get_type (void) G_GNUC_CONST;
entitasBullet* entitas_bullet_dup (const entitasBullet* self);
void entitas_bullet_free (entitasBullet* self);
GType entitas_enemy1_get_type (void) G_GNUC_CONST;
entitasEnemy1* entitas_enemy1_dup (const entitasEnemy1* self);
void entitas_enemy1_free (entitasEnemy1* self);
GType entitas_enemy2_get_type (void) G_GNUC_CONST;
entitasEnemy2* entitas_enemy2_dup (const entitasEnemy2* self);
void entitas_enemy2_free (entitasEnemy2* self);
GType entitas_enemy3_get_type (void) G_GNUC_CONST;
entitasEnemy3* entitas_enemy3_dup (const entitasEnemy3* self);
void entitas_enemy3_free (entitasEnemy3* self);
GType entitas_expires_get_type (void) G_GNUC_CONST;
entitasExpires* entitas_expires_dup (const entitasExpires* self);
void entitas_expires_free (entitasExpires* self);
GType entitas_health_get_type (void) G_GNUC_CONST;
entitasHealth* entitas_health_dup (const entitasHealth* self);
void entitas_health_free (entitasHealth* self);
GType entitas_hud_get_type (void) G_GNUC_CONST;
entitasHud* entitas_hud_dup (const entitasHud* self);
void entitas_hud_free (entitasHud* self);
GType entitas_index_get_type (void) G_GNUC_CONST;
entitasIndex* entitas_index_dup (const entitasIndex* self);
void entitas_index_free (entitasIndex* self);
GType entitas_layer_get_type (void) G_GNUC_CONST;
entitasLayer* entitas_layer_dup (const entitasLayer* self);
void entitas_layer_free (entitasLayer* self);
GType entitas_position_get_type (void) G_GNUC_CONST;
entitasPosition* entitas_position_dup (const entitasPosition* self);
void entitas_position_free (entitasPosition* self);
GType entitas_scale_get_type (void) G_GNUC_CONST;
entitasScale* entitas_scale_dup (const entitasScale* self);
void entitas_scale_free (entitasScale* self);
GType entitas_sprite_get_type (void) G_GNUC_CONST;
GType sdx_graphics_sprite_get_type (void) G_GNUC_CONST;
entitasSprite* entitas_sprite_dup (const entitasSprite* self);
void entitas_sprite_free (entitasSprite* self);
void entitas_sprite_copy (const entitasSprite* self, entitasSprite* dest);
void entitas_sprite_destroy (entitasSprite* self);
GType entitas_text_get_type (void) G_GNUC_CONST;
entitasText* entitas_text_dup (const entitasText* self);
void entitas_text_free (entitasText* self);
void entitas_text_copy (const entitasText* self, entitasText* dest);
void entitas_text_destroy (entitasText* self);
GType entitas_tint_get_type (void) G_GNUC_CONST;
entitasTint* entitas_tint_dup (const entitasTint* self);
void entitas_tint_free (entitasTint* self);
GType entitas_tween_get_type (void) G_GNUC_CONST;
entitasTween* entitas_tween_dup (const entitasTween* self);
void entitas_tween_free (entitasTween* self);
GType entitas_velocity_get_type (void) G_GNUC_CONST;
entitasVelocity* entitas_velocity_dup (const entitasVelocity* self);
void entitas_velocity_free (entitasVelocity* self);
entitasEntity* entitas_entity_dup (const entitasEntity* self);
void entitas_entity_free (entitasEntity* self);
void entitas_entity_copy (const entitasEntity* self, entitasEntity* dest);
void entitas_entity_destroy (entitasEntity* self);
GType entitas_buffer_get_type (void) G_GNUC_CONST;
entitasBuffer* entitas_buffer_dup (const entitasBuffer* self);
void entitas_buffer_free (entitasBuffer* self);
void entitas_buffer_copy (const entitasBuffer* self, entitasBuffer* dest);
void entitas_buffer_destroy (entitasBuffer* self);
void entitas_buffer_init (entitasBuffer *self, gint pool, gint size, entitasFactory factory, void* factory_target);
GType entitas_isystem_get_type (void) G_GNUC_CONST;
entitasISystem* entitas_isystem_dup (const entitasISystem* self);
void entitas_isystem_free (entitasISystem* self);

const guint64 ENTITAS_POW2[65] = {(guint64) 0x0000000000000000, (guint64) 0x0000000000000001, (guint64) 0x0000000000000002, (guint64) 0x0000000000000004, (guint64) 0x0000000000000008, (guint64) 0x0000000000000010, (guint64) 0x0000000000000020, (guint64) 0x0000000000000040, (guint64) 0x0000000000000080, (guint64) 0x0000000000000100, (guint64) 0x0000000000000200, (guint64) 0x0000000000000400, (guint64) 0x0000000000000800, (guint64) 0x0000000000001000, (guint64) 0x0000000000002000, (guint64) 0x0000000000004000, (guint64) 0x0000000000008000, (guint64) 0x0000000000010000, (guint64) 0x0000000000020000, (guint64) 0x0000000000040000, (guint64) 0x0000000000080000, (guint64) 0x0000000000100000, (guint64) 0x0000000000200000, (guint64) 0x0000000000400000, (guint64) 0x0000000000800000, (guint64) 0x0000000001000000, (guint64) 0x0000000002000000, (guint64) 0x0000000004000000, (guint64) 0x0000000008000000, (guint64) 0x0000000010000000, (guint64) 0x0000000020000000, (guint64) 0x0000000040000000, (guint64) 0x0000000080000000LL, (guint64) 0x0000000100000000LL, (guint64) 0x0000000200000000LL, (guint64) 0x0000000400000000LL, (guint64) 0x0000000800000000LL, (guint64) 0x0000001000000000LL, (guint64) 0x0000002000000000LL, (guint64) 0x0000004000000000LL, (guint64) 0x0000008000000000LL, (guint64) 0x0000010000000000LL, (guint64) 0x0000020000000000LL, (guint64) 0x0000040000000000LL, (guint64) 0x0000080000000000LL, (guint64) 0x0000100000000000LL, (guint64) 0x0000200000000000LL, (guint64) 0x0000400000000000LL, (guint64) 0x0000800000000000LL, (guint64) 0x0001000000000000LL, (guint64) 0x0002000000000000LL, (guint64) 0x0004000000000000LL, (guint64) 0x0008000000000000LL, (guint64) 0x0010000000000000LL, (guint64) 0x0020000000000000LL, (guint64) 0x0040000000000000LL, (guint64) 0x0080000000000000LL, (guint64) 0x0100000000000000LL, (guint64) 0x0200000000000000LL, (guint64) 0x0400000000000000LL, (guint64) 0x0800000000000000LL, (guint64) 0x1000000000000000LL, (guint64) 0x2000000000000000LL, (guint64) 0x4000000000000000LL, (guint64) 0x8000000000000000LL};

GQuark entitas_exception_quark (void) {
	return g_quark_from_static_string ("entitas_exception-quark");
}


void entitas_buffer_init (entitasBuffer *self, gint pool, gint size, entitasFactory factory, void* factory_target) {
	gint _tmp0_ = 0;
	gint _tmp1_ = 0;
	entitasFactory _tmp2_ = NULL;
	void* _tmp2__target = NULL;
	memset (self, 0, sizeof (entitasBuffer));
	_tmp0_ = pool;
	(*self).pool = _tmp0_;
	_tmp1_ = size;
	(*self).size = _tmp1_;
	_tmp2_ = factory;
	_tmp2__target = factory_target;
	((*self).factory_target_destroy_notify == NULL) ? NULL : ((*self).factory_target_destroy_notify ((*self).factory_target), NULL);
	(*self).factory = NULL;
	(*self).factory_target = NULL;
	(*self).factory_target_destroy_notify = NULL;
	(*self).factory = _tmp2_;
	(*self).factory_target = _tmp2__target;
	(*self).factory_target_destroy_notify = NULL;
}


void entitas_buffer_copy (const entitasBuffer* self, entitasBuffer* dest) {
	gint _tmp0_ = 0;
	gint _tmp1_ = 0;
	entitasFactory _tmp2_ = NULL;
	void* _tmp2__target = NULL;
	_tmp0_ = (*self).pool;
	(*dest).pool = _tmp0_;
	_tmp1_ = (*self).size;
	(*dest).size = _tmp1_;
	_tmp2_ = (*self).factory;
	_tmp2__target = (*self).factory_target;
	((*dest).factory_target_destroy_notify == NULL) ? NULL : ((*dest).factory_target_destroy_notify ((*dest).factory_target), NULL);
	(*dest).factory = NULL;
	(*dest).factory_target = NULL;
	(*dest).factory_target_destroy_notify = NULL;
	(*dest).factory = _tmp2_;
	(*dest).factory_target = _tmp2__target;
	(*dest).factory_target_destroy_notify = NULL;
}


void entitas_buffer_destroy (entitasBuffer* self) {
	((*self).factory_target_destroy_notify == NULL) ? NULL : ((*self).factory_target_destroy_notify ((*self).factory_target), NULL);
	(*self).factory = NULL;
	(*self).factory_target = NULL;
	(*self).factory_target_destroy_notify = NULL;
}


entitasBuffer* entitas_buffer_dup (const entitasBuffer* self) {
	entitasBuffer* dup;
	dup = g_new0 (entitasBuffer, 1);
	entitas_buffer_copy (self, dup);
	return dup;
}


void entitas_buffer_free (entitasBuffer* self) {
	entitas_buffer_destroy (self);
	g_free (self);
}


GType entitas_buffer_get_type (void) {
	static volatile gsize entitas_buffer_type_id__volatile = 0;
	if (g_once_init_enter (&entitas_buffer_type_id__volatile)) {
		GType entitas_buffer_type_id;
		entitas_buffer_type_id = g_boxed_type_register_static ("entitasBuffer", (GBoxedCopyFunc) entitas_buffer_dup, (GBoxedFreeFunc) entitas_buffer_free);
		g_once_init_leave (&entitas_buffer_type_id__volatile, entitas_buffer_type_id);
	}
	return entitas_buffer_type_id__volatile;
}


entitasISystem* entitas_isystem_dup (const entitasISystem* self) {
	entitasISystem* dup;
	dup = g_new0 (entitasISystem, 1);
	memcpy (dup, self, sizeof (entitasISystem));
	return dup;
}


void entitas_isystem_free (entitasISystem* self) {
	g_free (self);
}


GType entitas_isystem_get_type (void) {
	static volatile gsize entitas_isystem_type_id__volatile = 0;
	if (g_once_init_enter (&entitas_isystem_type_id__volatile)) {
		GType entitas_isystem_type_id;
		entitas_isystem_type_id = g_boxed_type_register_static ("entitasISystem", (GBoxedCopyFunc) entitas_isystem_dup, (GBoxedFreeFunc) entitas_isystem_free);
		g_once_init_leave (&entitas_isystem_type_id__volatile, entitas_isystem_type_id);
	}
	return entitas_isystem_type_id__volatile;
}



