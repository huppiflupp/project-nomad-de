import {
  IconAlertTriangle,
  IconAmbulance,
  IconAntenna,
  IconBandage,
  IconBarrel,
  IconBattery,
  IconBed,
  IconBolt,
  IconBuildingHospital,
  IconCampfire,
  IconCar,
  IconDoor,
  IconDroplet,
  IconFirstAidKit,
  IconFish,
  IconFlag,
  IconGasStation,
  IconHome,
  IconMapPinFilled,
  IconMeat,
  IconMountain,
  IconPackage,
  IconPill,
  IconRadio,
  IconRoute,
  IconSeeding,
  IconSkull,
  IconSolarPanel,
  IconStethoscope,
  IconTent,
  IconTool,
  IconToolsKitchen2,
  IconTractor,
  IconTrees,
  IconTruck,
  IconWheat,
  IconWifi,
} from '@tabler/icons-react'
import type { IconProps } from '@tabler/icons-react'
import type { ComponentType } from 'react'
import { t } from '~/i18n/runtime'

/**
 * The marker icon set: a curated 36, laid out as six rows of six.
 *
 * Deliberately named imports rather than `import * as TablerIcons`. The
 * namespace form pulls the entire icon library into the maps bundle -- when this
 * picker offered all of Tabler *and* all of Font Awesome it took the maps chunk
 * from 864 kB to 5,774 kB, and gave the user 160 pages to scroll through,
 * including brand logos and text-alignment glyphs. Neither is what someone
 * marking a water source needs.
 *
 * Adding an icon means adding it here, which is the point: the list stays
 * meaningful for marking a place on a map you are relying on offline.
 */
export type MarkerIconEntry = {
  /** Stored on the marker row, e.g. `tabler:IconDroplet`. */
  name: string
  /** Shown as the button tooltip. */
  label: string
  Icon: ComponentType<IconProps>
}

const entry = (
  Icon: ComponentType<IconProps>,
  tablerName: string,
  label: string
): MarkerIconEntry => ({ name: `tabler:${tablerName}`, label, Icon })

export const MARKER_ICONS: MarkerIconEntry[] = [
  // Water and food
  entry(IconDroplet, 'IconDroplet', t('Water')),
  entry(IconBarrel, 'IconBarrel', t('Water storage')),
  entry(IconToolsKitchen2, 'IconToolsKitchen2', t('Food')),
  entry(IconWheat, 'IconWheat', t('Grain or crops')),
  entry(IconMeat, 'IconMeat', t('Meat or game')),
  entry(IconFish, 'IconFish', t('Fishing')),

  // Shelter and living
  entry(IconHome, 'IconHome', t('Building')),
  entry(IconTent, 'IconTent', t('Camp')),
  entry(IconBed, 'IconBed', t('Shelter')),
  entry(IconDoor, 'IconDoor', t('Entrance')),
  entry(IconCampfire, 'IconCampfire', t('Fire')),
  entry(IconSeeding, 'IconSeeding', t('Garden')),

  // Medical
  entry(IconFirstAidKit, 'IconFirstAidKit', t('First aid')),
  entry(IconBuildingHospital, 'IconBuildingHospital', t('Hospital')),
  entry(IconStethoscope, 'IconStethoscope', t('Clinic')),
  entry(IconPill, 'IconPill', t('Medication')),
  entry(IconBandage, 'IconBandage', t('Supplies')),
  entry(IconAmbulance, 'IconAmbulance', t('Ambulance')),

  // Power and communications
  entry(IconBolt, 'IconBolt', t('Power')),
  entry(IconSolarPanel, 'IconSolarPanel', t('Solar')),
  entry(IconBattery, 'IconBattery', t('Battery')),
  entry(IconAntenna, 'IconAntenna', t('Antenna')),
  entry(IconRadio, 'IconRadio', t('Radio')),
  entry(IconWifi, 'IconWifi', t('Network')),

  // Transport and supply
  entry(IconGasStation, 'IconGasStation', t('Fuel')),
  entry(IconCar, 'IconCar', t('Vehicle')),
  entry(IconTruck, 'IconTruck', t('Truck')),
  entry(IconTractor, 'IconTractor', t('Machinery')),
  entry(IconPackage, 'IconPackage', t('Cache or supplies')),
  entry(IconTool, 'IconTool', t('Tools')),

  // Terrain, routes and hazards
  entry(IconMountain, 'IconMountain', t('High ground')),
  entry(IconTrees, 'IconTrees', t('Woodland')),
  entry(IconRoute, 'IconRoute', t('Route')),
  entry(IconFlag, 'IconFlag', t('Rally point')),
  entry(IconAlertTriangle, 'IconAlertTriangle', t('Hazard')),
  entry(IconSkull, 'IconSkull', t('Danger')),
]

/** The pin used when a marker has no icon, or names one no longer in the set. */
export const DEFAULT_MARKER_ICON = IconMapPinFilled

const BY_NAME = new Map(MARKER_ICONS.map((i) => [i.name, i.Icon]))

/**
 * Resolve a stored icon name to a component, falling back to the default pin.
 *
 * The fallback matters beyond bad data: a marker saved with an icon that is
 * later removed from the set must still render, rather than blanking the pin.
 */
export function resolveMarkerIcon(
  icon?: string | null,
  fallback: ComponentType<IconProps> = DEFAULT_MARKER_ICON
): ComponentType<IconProps> {
  if (!icon) return fallback
  return BY_NAME.get(icon) ?? fallback
}
