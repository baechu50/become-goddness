extends RefCounted

# 초기 자원
const INITIAL_POPULATION: int = 3
const INITIAL_FOOD: int = 5
const INITIAL_FAITH: int = 5

# 인구 시스템
const HUMAN_MAX_HEALTH: int = 100

# 업그레이드 시스템
const MAX_UPGRADE_LEVEL: int = 5
const COST_BASE_FAITH: int = 10
const COST_MULTIPLIER: float = 1.8

# 거주지
const RESIDENCE_BASE_TIME: int = 15
const RESIDENT_MULTIPLIER: float = 0.8
const RESIDENCE_BASE_CONSUMPTION: int = 2

# 밭
const FARM_BASE_PRODUCTION: int = 1
const FARM_BASE_CONSUMPTION: int = 10
const FARM_PRODUCTION_MULTIPLIER: float = 2.0
const FARM_CONSUMPTION_MULTIPLIER: float = 0.88

# 신전
const TEMPLE_BASE_PRODUCTION: int = 1
const TEMPLE_BASE_CONSUMPTION: int = 10
const TEMPLE_PRODUCTION_MULTIPLIER: float = 2.0
const TEMPLE_CONSUMPTION_MULTIPLIER: float = 0.88

# 식당
const RESTAURANT_BASE_PRODUCTION: int = 10
const RESTAURANT_BASE_CONSUMPTION: int = 1
const RESTAURANT_PRODUCTION_MULTIPLIER: float = 1.25
const RESTAURANT_CONSUMPTION_MULTIPLIER: float = 1.0

# 게임 시스템
const FACILITY_UPDATE_INTERVAL: int = 1
const EVENT_INTERVAL: int = 30
const TOKEN_PER_YEAR: int = 1

# UI 표시 관련
const HEALTH_GREEN_THRESHOLD: int = 70
const HEALTH_YELLOW_THRESHOLD: int = 30
