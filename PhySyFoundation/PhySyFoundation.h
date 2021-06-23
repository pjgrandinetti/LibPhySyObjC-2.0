//
//  PhySyFoundation.h
//
//  Created by PhySy Ltd on 10/7/11.
//  Copyright (c) 2008-2014 PhySy Ltd. All rights reserved.
//

/*!
 @header PhySyFoundation
 @copyright PhySy Ltd
 */

#import "CFAdditions.h"

/*!
 @enum PSBaseDimensionIndex
 @constant kPSLengthIndex index for length dimension.
 @constant kPSMassIndex index for mass dimension.
 @constant kPSTimeIndex index for time dimension.
 @constant kPSCurrentIndex index for current dimension.
 @constant kPSTemperatureIndex index for temperature dimension.
 @constant kPSAmountIndex index for amount dimension.
 @constant kPSLuminousIntensityIndex index for luminous intensity dimension.
 */
typedef enum {
    kPSLengthIndex = 0,
    kPSMassIndex = 1,
    kPSTimeIndex = 2,
    kPSCurrentIndex = 3,
    kPSTemperatureIndex = 4,
    kPSAmountIndex = 5,
    kPSLuminousIntensityIndex = 6,
} PSBaseDimensionIndex;

/*!
 @enum PSSIPrefix
 @constant kPSSIPrefixYocto SI Prefix yocto
 @constant kPSSIPrefixZepto SI Prefix zepto
 @constant kPSSIPrefixAtto SI Prefix atto
 @constant kPSSIPrefixFemto SI Prefix femto
 @constant kPSSIPrefixPico SI Prefix pico
 @constant kPSSIPrefixNano SI Prefix nano
 @constant kPSSIPrefixMicro SI Prefix micro
 @constant kPSSIPrefixMilli SI Prefix milli
 @constant kPSSIPrefixCenti SI Prefix centi
 @constant kPSSIPrefixDeci SI Prefix deci
 @constant kPSSIPrefixNone no SI Prefix
 @constant kPSSIPrefixDeca SI Prefix deca
 @constant kPSSIPrefixHecto SI Prefix hecto
 @constant kPSSIPrefixKilo SI Prefix kilo
 @constant kPSSIPrefixMega SI Prefix mega
 @constant kPSSIPrefixGiga SI Prefix giga
 @constant kPSSIPrefixTera SI Prefix tera
 @constant kPSSIPrefixPeta SI Prefix peta
 @constant kPSSIPrefixExa SI Prefix exa
 @constant kPSSIPrefixZetta SI Prefix zetta
 @constant kPSSIPrefixYotta SI Prefix yotta
 */
typedef enum {
    kPSSIPrefixYocto = -24,
    kPSSIPrefixZepto = -21,
    kPSSIPrefixAtto = -18,
    kPSSIPrefixFemto = -15,
    kPSSIPrefixPico = -12,
    kPSSIPrefixNano = -9,
    kPSSIPrefixMicro = -6,
    kPSSIPrefixMilli = -3,
    kPSSIPrefixCenti = -2,
    kPSSIPrefixDeci = -1,
    kPSSIPrefixNone = 0,
    kPSSIPrefixDeca = 1,
    kPSSIPrefixHecto = 2,
    kPSSIPrefixKilo = 3,
    kPSSIPrefixMega = 6,
    kPSSIPrefixGiga = 9,
    kPSSIPrefixTera = 12,
    kPSSIPrefixPeta = 15,
    kPSSIPrefixExa = 18,
    kPSSIPrefixZetta = 21,
    kPSSIPrefixYotta = 24
} PSSIPrefix;

#define kPSUnitMeter             CFSTR("meter")
#define kPSUnitMeters            CFSTR("meters")
#define kPSUnitGram              CFSTR("gram")
#define kPSUnitGrams             CFSTR("grams")
#define kPSUnitSecond            CFSTR("second")
#define kPSUnitSeconds           CFSTR("seconds")
#define kPSUnitAmpere            CFSTR("ampere")
#define kPSUnitAmperes           CFSTR("amperes")
#define kPSUnitKelvin            CFSTR("kelvin")
#define kPSUnitMole              CFSTR("mole")
#define kPSUnitMoles             CFSTR("moles")
#define kPSUnitCandela           CFSTR("candela")
#define kPSUnitCandelas          CFSTR("candelas")

#define kPSMinute       60.
#define kPSHour         3600            //  60.*60.
#define kPSDay          86400           //  60.*60*24.
#define kPSWeek         604800          //  60.*60*24.*7.
#define kPSMonth        2629800         //  365.25*86400/12.
#define kPSYear         31557600        //  365.25*86400
#define kPSDecade       315576000       //  365.25*86400*10
#define kPSCentury      3155760000      //  365.25*86400*100
#define kPSMillennium   31557600000     //  365.25*86400*1000

#define kPSPi                       3.141592653589793
#define kPSEulersNumber             2.718281828459045

#define kPSSpeedOfLight             299792458
#define kPSElementaryCharge         1.602176634e-19
#define kPSPlanckConstant           6.62607015e-34
#define kPSBoltmannConstant         1.380649e-23
#define kPSAvogadroConstant         6.02214076e23
#define kPSStefanBoltzmannConstant  5.670374419e-8
#define kPSWeinDisplacementConstant 2.897771955e-3
#define kPSElectronMass             9.109383701528e-31
#define kPSProtonMass               1.6726219236951e-27
#define kPSNeutronMass              1.6749274980495e-27
#define kPSMuonMass                 1.883531627459132e-28
#define kPSAtomicMassConstant       1.6605390666050e-27
#define kPSAlphaParticleMass        6.64465723082e-27
#define kPSGravitaionalConstant     6.6743015e-11

#define kPSElectricConstant         8.854187817620389e-12  // Defined as 1/sqrt(c_0^2*µ_0)

// Above updated for 2019 mass definitions

#define kPSElectronMagneticMoment   -928.4764620e-26
#define kPSElectronGFactor          -2.00231930436182

#define kPSProtonMagneticMoment     1.4106067873e-26
#define kPSProtonGFactor            5.585694702

#define kPSNeutronMagneticMoment    -0.96623650e-26
#define kPSNeutronGFactor           -3.82608545

#define kPSMuonMagneticMoment       -4.49044826e-26
#define kPSMuonGFactor              -2.0023318418

#define kPSGravityAcceleration      9.80665



/*! @constant kPSQuantityDimensionless */
#define kPSQuantityDimensionless                        CFSTR("dimensionless")


/*! @constant kPSQuantityLength */
#define kPSQuantityLength                               CFSTR("length")
/*! @constant kPSQuantityInverseLength */
#define kPSQuantityInverseLength                        CFSTR("inverse length")
/*! @constant kPSQuantityWavenumber */
#define kPSQuantityWavenumber                           CFSTR("wavenumber")
/*! @constant kPSQuantityLengthRatio */
#define kPSQuantityLengthRatio                          CFSTR("length ratio")
/*! @constant kPSQuantityPlaneAngle */
#define kPSQuantityPlaneAngle                           CFSTR("plane angle")


/*! @constant kPSQuantityMass */
#define kPSQuantityMass                                 CFSTR("mass")
/*! @constant kPSQuantityInverseMass */
#define kPSQuantityInverseMass                          CFSTR("inverse mass")
/*! @constant kPSQuantityMassRatio */
#define kPSQuantityMassRatio                            CFSTR("mass ratio")


/*! @constant kPSQuantityTime */
#define kPSQuantityTime                                 CFSTR("time")
/*! @constant kPSQuantityInverseTime */
#define kPSQuantityInverseTime                          CFSTR("inverse time")
/*! @constant kPSQuantityFrequency */
#define kPSQuantityFrequency                            CFSTR("frequency")
/*! @constant kPSQuantityRadioactivity */
#define kPSQuantityRadioactivity                        CFSTR("radioactivity")
/*! @constant kPSQuantityTimeRatio */
#define kPSQuantityTimeRatio                            CFSTR("time ratio")
/*! @constant kPSQuantityFrequencyRatio */
#define kPSQuantityFrequencyRatio                       CFSTR("frequency ratio")

/*! @constant kPSQuantityInverseTimeSquared */
#define kPSQuantityInverseTimeSquared                   CFSTR("inverse time squared")


/*! @constant kPSQuantityCurrent */
#define kPSQuantityCurrent                              CFSTR("current")
/*! @constant kPSQuantityInverseCurrent */
#define kPSQuantityInverseCurrent                       CFSTR("inverse current")
/*! @constant kPSQuantityCurrentRatio */
#define kPSQuantityCurrentRatio                         CFSTR("current ratio")


/*! @constant kPSQuantityTemperature */
#define kPSQuantityTemperature                          CFSTR("temperature")
/*! @constant kPSQuantityInverseTemperature */
#define kPSQuantityInverseTemperature                   CFSTR("inverse temperature")
/*! @constant kPSQuantityTemperatureRatio */
#define kPSQuantityTemperatureRatio                     CFSTR("temperature ratio")

/*! @constant kPSQuantityTemperatureGradient */
#define kPSQuantityTemperatureGradient                  CFSTR("temperature gradient")


/*! @constant kPSQuantityAmount */
#define kPSQuantityAmount                               CFSTR("amount")
/*! @constant kPSQuantityInverseAmount */
#define kPSQuantityInverseAmount                        CFSTR("inverse amount")
/*! @constant kPSQuantityAmountRatio */
#define kPSQuantityAmountRatio                          CFSTR("amount ratio")


/*! @constant kPSQuantityLuminousIntensity */
#define kPSQuantityLuminousIntensity                    CFSTR("luminous intensity")
/*! @constant kPSQuantityInverseLuminousIntensity */
#define kPSQuantityInverseLuminousIntensity             CFSTR("inverse luminous intensity")
/*! @constant kPSQuantityLuminousIntensityRatio */
#define kPSQuantityLuminousIntensityRatio               CFSTR("luminous intensity ratio")


/*! @constant kPSQuantityArea */
#define kPSQuantityArea                                 CFSTR("area")
/*! @constant kPSQuantityInverseArea */
#define kPSQuantityInverseArea                          CFSTR("inverse area")
/*! @constant kPSQuantityAreaRatio */
#define kPSQuantityAreaRatio                            CFSTR("area ratio")
/*! @constant kPSQuantitySolidAngle */
#define kPSQuantitySolidAngle                           CFSTR("solid angle")


/*! @constant kPSQuantityVolume */
#define kPSQuantityVolume                               CFSTR("volume")
/*! @constant kPSQuantityInverseVolume */
#define kPSQuantityInverseVolume                        CFSTR("inverse volume")
/*! @constant kPSQuantityVolumeRatio */
#define kPSQuantityVolumeRatio                          CFSTR("volume ratio")


/*! @constant kPSQuantitySpeed */
#define kPSQuantitySpeed                                CFSTR("speed")
/*! @constant kPSQuantityVelocity */
#define kPSQuantityVelocity                             CFSTR("velocity")

/*! @constant kPSQuantityLinearMomentum */
#define kPSQuantityLinearMomentum                       CFSTR("linear momentum")

/*! @constant kPSQuantityAngularMomentum */
#define kPSQuantityAngularMomentum                      CFSTR("angular momentum")

/*! @constant kPSQuantityMomentOfInertia */
#define kPSQuantityMomentOfInertia                      CFSTR("moment of inertia")

/*! @constant kPSQuantityAcceleration */
#define kPSQuantityAcceleration                         CFSTR("acceleration")

/*! @constant kPSQuantityMassFlowRate */
#define kPSQuantityMassFlowRate                         CFSTR("mass flow rate")

/*! @constant kPSQuantityMassFlux */
#define kPSQuantityMassFlux                             CFSTR("mass flux")

/*! @constant kPSQuantityDensity */
#define kPSQuantityDensity                              CFSTR("density")

/*! @constant kPSQuantitySpecificGravity */
#define kPSQuantitySpecificGravity                      CFSTR("specific gravity")

/*! @constant kPSQuantitySpecificSurfaceArea */
#define kPSQuantitySpecificSurfaceArea                  CFSTR("specific surface area")

/*! @constant kPSQuantitySurfaceAreaToVolumeRatio */
#define kPSQuantitySurfaceAreaToVolumeRatio             CFSTR("surface area to volume ratio")

/*! @constant kPSQuantitySurfaceDensity */
#define kPSQuantitySurfaceDensity                       CFSTR("surface density")

/*! @constant kPSQuantitySpecificVolume */
#define kPSQuantitySpecificVolume                       CFSTR("specific volume")

/*! @constant kPSQuantityCurrentDensity */
#define kPSQuantityCurrentDensity                       CFSTR("current density")

/*! @constant kPSQuantityMagneticFieldStrength */
#define kPSQuantityMagneticFieldStrength                CFSTR("magnetic field strength")

/*! @constant kPSQuantityLuminance */
#define kPSQuantityLuminance                            CFSTR("luminance")

/*! @constant kPSQuantityRefractiveIndex */
#define kPSQuantityRefractiveIndex                      CFSTR("refractive index")

/*! @constant kPSQuantityFluidity */
#define kPSQuantityFluidity                             CFSTR("fluidity")

/*! @constant kPSQuantityMomentOfForce */
#define kPSQuantityMomentOfForce                        CFSTR("moment of force")

/*! @constant kPSQuantitySurfaceTension */
#define kPSQuantitySurfaceTension                       CFSTR("surface tension")

/*! @constant kPSQuantitySurfaceEnergy */
#define kPSQuantitySurfaceEnergy                        CFSTR("surface energy")

/*! @constant kPSQuantityAngularSpeed */
#define kPSQuantityAngularSpeed                         CFSTR("angular speed")

/*! @constant kPSQuantityAngularVelocity */
#define kPSQuantityAngularVelocity                      CFSTR("angular velocity")

/*! @constant kPSQuantityAngularAcceleration */
#define kPSQuantityAngularAcceleration                  CFSTR("angular acceleration")

/*! @constant kPSQuantityHeatFluxDensity */
#define kPSQuantityHeatFluxDensity                      CFSTR("heat flux density")

/*! @constant kPSQuantityIrradiance */
#define kPSQuantityIrradiance                           CFSTR("irradiance")

/*! @constant kPSQuantitySpectralRadiantFluxDensity */
#define kPSQuantitySpectralRadiantFluxDensity           CFSTR("spectral radiant flux density")

/*! @constant kPSQuantityHeatCapacity */
#define kPSQuantityHeatCapacity                         CFSTR("heat capacity")
/*! @constant kPSQuantityEntropy */
#define kPSQuantityEntropy                              CFSTR("entropy")

/*! @constant kPSQuantitySpecificHeatCapacity */
#define kPSQuantitySpecificHeatCapacity                 CFSTR("specific heat capacity")
/*! @constant kPSQuantitySpecificEntropy */
#define kPSQuantitySpecificEntropy                      CFSTR("specific entropy")

/*! @constant kPSQuantitySpecificEnergy */
#define kPSQuantitySpecificEnergy                       CFSTR("specific energy")

/*! @constant kPSQuantityThermalConductance */
#define kPSQuantityThermalConductance                  CFSTR("thermal conductance")

/*! @constant kPSQuantityThermalConductivity */
#define kPSQuantityThermalConductivity                  CFSTR("thermal conductivity")

/*! @constant kPSQuantityEnergyDensity */
#define kPSQuantityEnergyDensity                        CFSTR("energy density")

/*! @constant kPSQuantityElectricFieldStrength */
#define kPSQuantityElectricFieldStrength                CFSTR("electric field strength")

/*! @constant kPSQuantityElectricFieldGradient */
#define kPSQuantityElectricFieldGradient                CFSTR("electric field gradient")

/*! @constant kPSQuantityElectricChargeDensity */
#define kPSQuantityElectricChargeDensity                CFSTR("electric charge density")

/*! @constant kPSQuantitySurfaceChargeDensity */
#define kPSQuantitySurfaceChargeDensity                 CFSTR("surface charge density")

/*! @constant kPSQuantityElectricFlux */
#define kPSQuantityElectricFlux                         CFSTR("electric flux")

/*! @constant kPSQuantityElectricFluxDensity */
#define kPSQuantityElectricFluxDensity                  CFSTR("electric flux density")

/*! @constant kPSQuantityElectricDisplacement */
#define kPSQuantityElectricDisplacement                 CFSTR("electric displacement")

/*! @constant kPSQuantityPermittivity */
#define kPSQuantityPermittivity                         CFSTR("permittivity")

/*! @constant kPSQuantityPermeability */
#define kPSQuantityPermeability                         CFSTR("permeability")

/*! @constant kPSQuantityMolarEnergy */
#define kPSQuantityMolarEnergy                          CFSTR("molar energy")

/*! @constant kPSQuantityMolarEntropy */
#define kPSQuantityMolarEntropy                         CFSTR("molar entropy")

/*! @constant kPSQuantityMolarHeatCapacity */
#define kPSQuantityMolarHeatCapacity                    CFSTR("molar heat capacity")

/*! @constant kPSQuantityMolarMass */
#define kPSQuantityMolarMass                            CFSTR("molar mass")

/*! @constant kPSQuantityMolality */
#define kPSQuantityMolality                             CFSTR("molality")

/*! @constant kPSQuantityDiffusionFlux */
#define kPSQuantityDiffusionFlux                        CFSTR("diffusion flux")

/*! @constant kPSQuantityMassToChargeRatio */
#define kPSQuantityMassToChargeRatio                    CFSTR("mass to charge ratio")

/*! @constant kPSQuantityChargeToMassRatio */
#define kPSQuantityChargeToMassRatio                    CFSTR("charge to mass ratio")

/*! @constant kPSQuantityRadiationExposure */
#define kPSQuantityRadiationExposure                    CFSTR("radiation exposure")

/*! @constant kPSQuantityAbsorbedDoseRate */
#define kPSQuantityAbsorbedDoseRate                     CFSTR("absorbed dose rate")

/*! @constant kPSQuantityRadiantIntensity */
#define kPSQuantityRadiantIntensity                     CFSTR("radiant intensity")

/*! @constant kPSQuantitySpectralRadiantIntensity */
#define kPSQuantitySpectralRadiantIntensity             CFSTR("spectral radiant intensity")

/*! @constant kPSQuantityRadiance */
#define kPSQuantityRadiance                             CFSTR("radiance")

/*! @constant kPSQuantitySpectralRadiance */
#define kPSQuantitySpectralRadiance                     CFSTR("spectral radiance")

/*! @constant kPSQuantityPorosity */
#define kPSQuantityPorosity                             CFSTR("porosity")

/*! @constant kPSQuantityAngularFrequency */
#define kPSQuantityAngularFrequency                     CFSTR("angular frequency")

/*! @constant kPSQuantityForce */
#define kPSQuantityForce                                CFSTR("force")

/*! @constant kPSQuantityTorque */
#define kPSQuantityTorque                               CFSTR("torque")

/*! @constant kPSQuantityPressure */
#define kPSQuantityPressure                             CFSTR("pressure")
/*! @constant kPSQuantityStress */
#define kPSQuantityStress                               CFSTR("stress")
/*! @constant kPSQuantityElasticModulus */
#define kPSQuantityElasticModulus                       CFSTR("elastic modulus")

/*! @constant kPSQuantityCompressibility */
#define kPSQuantityCompressibility                      CFSTR("compressibility")
/*! @constant kPSQuantityStressOpticCoefficient */
#define kPSQuantityStressOpticCoefficient               CFSTR("stress-optic coefficient")

/*! @constant kPSQuantityPressureGradient */
#define kPSQuantityPressureGradient                     CFSTR("pressure gradient")

/*! @constant kPSQuantityEnergy */
#define kPSQuantityEnergy                               CFSTR("energy")

/*! @constant kPSQuantitySpectralRadiantEnergy */
#define kPSQuantitySpectralRadiantEnergy                CFSTR("spectral radiant energy")

/*! @constant kPSQuantityPower */
#define kPSQuantityPower                                CFSTR("power")

/*! @constant kPSQuantitySpectralPower */
#define kPSQuantitySpectralPower                        CFSTR("spectral power")

/*! @constant kPSQuantityVolumePowerDensity */
#define kPSQuantityVolumePowerDensity                   CFSTR("volume power density")

/*! @constant kPSQuantitySpecificPower */
#define kPSQuantitySpecificPower                        CFSTR("specific power")

/*! @constant kPSQuantityRadiantFlux */
#define kPSQuantityRadiantFlux                          CFSTR("radiant flux")

/*! @constant kPSQuantityElectricCharge */
#define kPSQuantityElectricCharge                       CFSTR("electric charge")

/*! @constant kPSQuantityAmountOfElectricity */
#define kPSQuantityAmountOfElectricity                  CFSTR("amount of electricity")

/*! @constant kPSQuantityElectricPotentialDifference */
#define kPSQuantityElectricPotentialDifference          CFSTR("electric potential difference")

/*! @constant kPSQuantityElectromotiveForce */
#define kPSQuantityElectromotiveForce                   CFSTR("electromotive force")

/*! @constant kPSQuantityElectricPolarizability */
#define kPSQuantityElectricPolarizability                 CFSTR("electric polarizability")

/*! @constant kPSQuantityElectricDipoleMoment */
#define kPSQuantityElectricDipoleMoment                 CFSTR("electric dipole moment")

/*! @constant kPSQuantityVoltage */
#define kPSQuantityVoltage                              CFSTR("voltage")

/*! @constant kPSQuantityCapacitance */
#define kPSQuantityCapacitance                          CFSTR("capacitance")

/*! @constant kPSQuantityElectricResistance */
#define kPSQuantityElectricResistance                   CFSTR("electric resistance")

/*! @constant kPSQuantityElectricResistancePerLength */
#define kPSQuantityElectricResistancePerLength          CFSTR("electric resistance per length")

/*! @constant kPSQuantityElectricResistivity */
#define kPSQuantityElectricResistivity                  CFSTR("electric resistivity")

/*! @constant kPSQuantityElectricConductance */
#define kPSQuantityElectricConductance                  CFSTR("electric conductance")

/*! @constant kPSQuantityElectricConductivity */
#define kPSQuantityElectricConductivity                 CFSTR("electric conductivity")

/*! @constant kPSQuantityElectricalMobility */
#define kPSQuantityElectricalMobility                   CFSTR("electrical mobility")

/*! @constant kPSQuantityMolarConductivity */
#define kPSQuantityMolarConductivity                    CFSTR("molar conductivity")

/*! @constant kPSQuantityMagneticDipoleMoment */
#define kPSQuantityMagneticDipoleMoment                 CFSTR("magnetic dipole moment")

/*! @constant kPSQuantityMagneticDipoleMomentRatio */
#define kPSQuantityMagneticDipoleMomentRatio            CFSTR("magnetic dipole moment ratio")

/*! @constant kPSQuantityMagneticFlux */
#define kPSQuantityMagneticFlux                         CFSTR("magnetic flux")

/*! @constant kPSQuantityMagneticFluxDensity */
#define kPSQuantityMagneticFluxDensity                  CFSTR("magnetic flux density")

/*! @constant kPSQuantityMolarMagneticSusceptibility */
#define kPSQuantityMolarMagneticSusceptibility          CFSTR("molar magnetic susceptibility")

/*! @constant kPSQuantityInverseMagneticFluxDensity */
#define kPSQuantityInverseMagneticFluxDensity           CFSTR("inverse magnetic flux density")

/*! @constant kPSQuantityMagneticFieldGradient */
#define kPSQuantityMagneticFieldGradient                CFSTR("magnetic field gradient")

/*! @constant kPSQuantityInductance */
#define kPSQuantityInductance                           CFSTR("inductance")

/*! @constant kPSQuantityLuminousFlux */
#define kPSQuantityLuminousFlux                         CFSTR("luminous flux")

/*! @constant kPSQuantityLuminousFluxDensity */
#define kPSQuantityLuminousFluxDensity                  CFSTR("luminous flux density")

/*! @constant kPSQuantityLuminousEnergy */
#define kPSQuantityLuminousEnergy                       CFSTR("luminous energy")

/*! @constant kPSQuantityIlluminance */
#define kPSQuantityIlluminance                          CFSTR("illuminance")

/*! @constant kPSQuantityAbsorbedDose */
#define kPSQuantityAbsorbedDose                         CFSTR("absorbed dose")

/*! @constant kPSQuantityDoseEquivalent */
#define kPSQuantityDoseEquivalent                       CFSTR("dose equivalent")

/*! @constant kPSQuantityCatalyticActivity */
#define kPSQuantityCatalyticActivity                    CFSTR("catalytic activity")

/*! @constant kPSQuantityCatalyticActivityConcentration */
#define kPSQuantityCatalyticActivityConcentration       CFSTR("catalytic activity concentration")

/*! @constant kPSQuantityCatalyticActivityContent */
#define kPSQuantityCatalyticActivityContent             CFSTR("catalytic activity content")

/*! @constant kPSQuantityAction */
#define kPSQuantityAction                               CFSTR("action")

/*! @constant kPSQuantityReducedAction */
#define kPSQuantityReducedAction                        CFSTR("reduced action")

/*! @constant kPSQuantityKinematicViscosity */
#define kPSQuantityKinematicViscosity                   CFSTR("kinematic viscosity")

/*! @constant kPSQuantityDiffusionCoefficient */
#define kPSQuantityDiffusionCoefficient                 CFSTR("diffusion coefficient")

/*! @constant kPSQuantityCirculation */
#define kPSQuantityCirculation                          CFSTR("circulation")

/*! @constant kPSQuantityDynamicViscosity */
#define kPSQuantityDynamicViscosity                     CFSTR("dynamic viscosity")

/*! @constant kPSQuantityAmountConcentration */
#define kPSQuantityAmountConcentration                  CFSTR("amount concentration")

/*! @constant kPSQuantityMassConcentration */
#define kPSQuantityMassConcentration                    CFSTR("mass concentration")

/*! @constant kPSQuantityChargeToAmountRatio */
#define kPSQuantityChargeToAmountRatio                      CFSTR("charge to amount ratio")

/*! @constant kPSQuantityGravitationalConstant */
#define kPSQuantityGravitationalConstant                CFSTR("gravitational constant")

/*! @constant kPSQuantityLengthPerVolume */
#define kPSQuantityLengthPerVolume                      CFSTR("distance per volume")

/*! @constant kPSQuantityVolumePerLength */
#define kPSQuantityVolumePerLength                      CFSTR("volume per length")

/*! @constant kPSQuantityVolumetricFlowRate */
#define kPSQuantityVolumetricFlowRate                   CFSTR("volumetric flow rate")

/*! @constant kPSQuantityFrequencyPerMagneticFluxDensity */
#define kPSQuantityFrequencyPerMagneticFluxDensity      CFSTR("frequency per magnetic flux density")

/*! @constant kPSQuantityFrequencyPerElectricFieldGradient */
#define kPSQuantityFrequencyPerElectricFieldGradient      CFSTR("frequency per electric field gradient")

/*! @constant kPSQuantityFrequencyPerElectricFieldGradientSquared */
#define kPSQuantityFrequencyPerElectricFieldGradientSquared      CFSTR("frequency per electric field gradient squared")

/*! @constant kPSQuantityPowerPerLuminousFlux */
#define kPSQuantityPowerPerLuminousFlux                 CFSTR("power per luminous flux")

/*! @constant kPSQuantityLuminousEfficacy */
#define kPSQuantityLuminousEfficacy                     CFSTR("luminous efficacy")

/*! @constant kPSQuantityRockPermeability */
#define kPSQuantityRockPermeability                     CFSTR("rock permeability")

/*! @constant kPSQuantityGyromagneticRatio */
#define kPSQuantityGyromagneticRatio                    CFSTR("gyromagnetic ratio")

/*! @constant kPSQuantityHeatTransferCoefficient */
#define kPSQuantityHeatTransferCoefficient              CFSTR("heat transfer coefficient")

/*! @constant kPSQuantityGasPermeance */
#define kPSQuantityGasPermeance                         CFSTR("gas permeance")

/*! @constant kPSQuantityPowerPerAreaPerTemperatureToFourthPower */
#define kPSQuantityPowerPerAreaPerTemperatureToFourthPower        CFSTR("stefan-boltzmann constant")

/*! @constant kPSQuantityFirstHyperPolarizability */
#define kPSQuantityFirstHyperPolarizability                 CFSTR("first hyperpolarizability")

/*! @constant kPSQuantitySecondHyperPolarizability */
#define kPSQuantitySecondHyperPolarizability                CFSTR("second hyperpolarizability")

/*! @constant kPSQuantityElectricQuadrupoleMoment */
#define kPSQuantityElectricQuadrupoleMoment                 CFSTR("electric quadrupole moment")

/*! @constant kPSQuantityMagnetizability */
#define kPSQuantityMagnetizability                          CFSTR("magnetizability")

/*! @constant kPSQuantitySecondRadiationConstant */
#define kPSQuantitySecondRadiationConstant                  CFSTR("second radiation constant")

/*! @constant kPSQuantityWavelengthDisplacementConstant */
#define kPSQuantityWavelengthDisplacementConstant           CFSTR("wavelength displacement constant")

/*! @constant kPSQuantityFineStructureConstant */
#define kPSQuantityFineStructureConstant                    CFSTR("fine structure constant")

/*! @constant kPSQuantityRatePerAmountConcentrationPerTime */
#define kPSQuantityRatePerAmountConcentrationPerTime        CFSTR("inverse amount concentration inverse time")


#import "PSDimensionality.h"
#import "PSDimensionalityParser.h"
#import "PSUnit.h"
#import "PSUnitParser.h"
#import "PSQuantity.h"
#import "PSScalar.h"
#import "PSScalarConstants.h"
#import "PSScalarParser.h"
#import "PSTreeNode.h"
#import "PSPList.h"
