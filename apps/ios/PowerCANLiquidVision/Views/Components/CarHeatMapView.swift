import SwiftUI

struct CarHeatMapView: View {
    let heatLevel: Double
    let coolantTemp: Double
    let rpm: Double
    let speed: Double

    @State private var pulsePhase: CGFloat = 0
    @State private var glowIntensity: Double = 0.3

    private var heatColor: Color {
        LVTheme.Colors.heatColor(for: heatLevel)
    }

    private var coolantNorm: Double {
        min(max((coolantTemp - 20) / 90.0, 0), 1)
    }

    private var rpmNorm: Double {
        min(rpm / 6000, 1)
    }

    private var speedNorm: Double {
        min(speed / 180, 1)
    }

    // Car image is HORIZONTAL: 600x286 (2.1:1 aspect)
    // LEFT side = tail/exhaust, RIGHT side = nose/engine
    // Body height profile analysis:
    //   Rear wheel arch peak:  nx=0.22 (x~130)  body height=257
    //   Front wheel arch peak: nx=0.77 (x~460)  body height=257
    //   Engine bay:            nx=0.85           under the hood
    //   Exhaust:               nx=0.10           tail end
    //   Wheels protrude to:    ny=0.05 (top) and ny=0.95 (bottom)
    private let imgAspect: CGFloat = 600.0 / 286.0

    var body: some View {
        GeometryReader { geo in
            let imgW = min(geo.size.width - 20, 350.0)
            let imgH = imgW / imgAspect

            ZStack {
                ambientGlow

                ZStack {
                    carImage(width: imgW)
                        .colorMultiply(heatColor.opacity(0.10 + glowIntensity * 0.20))

                    carImage(width: imgW)
                        .blendMode(.screen)

                    heatZones(imgW: imgW, imgH: imgH)
                }
                .compositingGroup()
                .shadow(color: heatColor.opacity(glowIntensity * 0.45), radius: 16)
                .shadow(color: heatColor.opacity(glowIntensity * 0.15), radius: 32)
                .scaleEffect(1.0 + pulsePhase * 0.005)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(height: 200)
        .padding(.horizontal, 12)
        .onAppear { startAnimations() }
        .onChange(of: heatLevel) { _, _ in startAnimations() }
    }

    private var ambientGlow: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        heatColor.opacity(glowIntensity * 0.08),
                        .clear
                    ],
                    center: .center,
                    startRadius: 10,
                    endRadius: 180
                )
            )
    }

    private func carImage(width: CGFloat) -> some View {
        Image("car_top")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
    }

    private func offset(nx: Double, ny: Double, imgW: CGFloat, imgH: CGFloat) -> CGSize {
        CGSize(width: (nx - 0.5) * imgW, height: (ny - 0.5) * imgH)
    }

    private func heatZones(imgW: CGFloat, imgH: CGFloat) -> some View {
        ZStack {
            // ENGINE (under hood, right-center of image)
            radialHotspot(
                color: LVTheme.Colors.heatColor(for: coolantNorm),
                intensity: glowIntensity * 0.8,
                innerR: 4, outerR: imgW * 0.10,
                size: imgW * 0.22
            )
            .offset(offset(nx: 0.85, ny: 0.50, imgW: imgW, imgH: imgH))

            // FRONT LEFT WHEEL (top-right area, near nose)
            brakeHotspot(norm: speedNorm, size: imgH * 0.28)
                .offset(offset(nx: 0.77, ny: 0.10, imgW: imgW, imgH: imgH))

            // FRONT RIGHT WHEEL (bottom-right area, near nose)
            brakeHotspot(norm: speedNorm, size: imgH * 0.28)
                .offset(offset(nx: 0.77, ny: 0.90, imgW: imgW, imgH: imgH))

            // REAR LEFT WHEEL (top-left area, near tail)
            brakeHotspot(norm: speedNorm * 0.6, size: imgH * 0.26)
                .offset(offset(nx: 0.22, ny: 0.10, imgW: imgW, imgH: imgH))

            // REAR RIGHT WHEEL (bottom-left area, near tail)
            brakeHotspot(norm: speedNorm * 0.6, size: imgH * 0.26)
                .offset(offset(nx: 0.22, ny: 0.90, imgW: imgW, imgH: imgH))

            // EXHAUST (tail end, left side of image)
            radialHotspot(
                color: LVTheme.Colors.heatColor(for: rpmNorm),
                intensity: glowIntensity * 0.55,
                innerR: 3, outerR: imgW * 0.06,
                size: imgW * 0.14
            )
            .offset(offset(nx: 0.08, ny: 0.50, imgW: imgW, imgH: imgH))

            // TRANSMISSION TUNNEL (center of car)
            radialHotspot(
                color: LVTheme.Colors.heatColor(for: coolantNorm * 0.4),
                intensity: glowIntensity * 0.25,
                innerR: 3, outerR: imgW * 0.08,
                size: imgW * 0.18
            )
            .offset(offset(nx: 0.50, ny: 0.50, imgW: imgW, imgH: imgH))
        }
    }

    private func radialHotspot(
        color: Color,
        intensity: Double,
        innerR: CGFloat,
        outerR: CGFloat,
        size: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(intensity),
                        color.opacity(intensity * 0.35),
                        .clear
                    ],
                    center: .center,
                    startRadius: innerR,
                    endRadius: outerR
                )
            )
            .frame(width: size, height: size)
    }

    private func brakeHotspot(norm: Double, size: CGFloat) -> some View {
        let brakeColor = LVTheme.Colors.heatColor(for: norm)
        let effectiveIntensity = glowIntensity * max(norm, 0.15)
        return Circle()
            .fill(
                RadialGradient(
                    colors: [
                        brakeColor.opacity(effectiveIntensity * 0.6),
                        brakeColor.opacity(effectiveIntensity * 0.2),
                        .clear
                    ],
                    center: .center,
                    startRadius: 2,
                    endRadius: size * 0.45
                )
            )
            .frame(width: size, height: size)
    }

    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.0 + (1.0 - heatLevel) * 0.8).repeatForever(autoreverses: true)) {
            pulsePhase = 1.0
            glowIntensity = 0.3 + heatLevel * 0.55
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 30) {
            CarHeatMapView(heatLevel: 0.3, coolantTemp: 50, rpm: 1500, speed: 40)
                .liquidGlass(cornerRadius: 24)
            CarHeatMapView(heatLevel: 0.85, coolantTemp: 98, rpm: 5200, speed: 150)
                .liquidGlass(cornerRadius: 24)
        }
    }
}
