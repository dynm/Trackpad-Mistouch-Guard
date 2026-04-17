import AppKit

enum AppLogo {
    static func makeAppIcon(size: CGFloat = 512) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            drawAppIcon(in: rect)
            return true
        }
        image.isTemplate = false
        return image
    }

    static func makeStatusImage(size: CGFloat = 18) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            drawStatusIcon(in: rect)
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func drawAppIcon(in rect: CGRect) {
        let inset = rect.width * 0.07
        let iconRect = rect.insetBy(dx: inset, dy: inset)
        let background = NSBezierPath(
            roundedRect: iconRect,
            xRadius: rect.width * 0.22,
            yRadius: rect.width * 0.22
        )

        let gradient = NSGradient(colors: [
            NSColor(calibratedRed: 0.98, green: 0.78, blue: 0.22, alpha: 1),
            NSColor(calibratedRed: 0.96, green: 0.55, blue: 0.13, alpha: 1),
        ])!
        gradient.draw(in: background, angle: -90)

        let innerShadow = NSShadow()
        innerShadow.shadowColor = NSColor(calibratedWhite: 1, alpha: 0.22)
        innerShadow.shadowBlurRadius = rect.width * 0.03
        innerShadow.shadowOffset = NSSize(width: 0, height: -rect.width * 0.012)
        NSGraphicsContext.saveGraphicsState()
        innerShadow.set()
        NSColor(calibratedWhite: 1, alpha: 0.16).setStroke()
        background.lineWidth = rect.width * 0.01
        background.stroke()
        NSGraphicsContext.restoreGraphicsState()

        let symbolRect = CGRect(
            x: iconRect.minX + iconRect.width * 0.18,
            y: iconRect.minY + iconRect.height * 0.16,
            width: iconRect.width * 0.54,
            height: iconRect.height * 0.56
        )
        if let symbolImage = symbolImage(
            name: "hand.raised.fill",
            pointSize: symbolRect.height,
            weight: .medium,
            scale: .large
        ) {
            symbolImage.draw(in: symbolRect)
        }

        let shieldRect = CGRect(
            x: iconRect.maxX - iconRect.width * 0.37,
            y: iconRect.minY + iconRect.height * 0.12,
            width: iconRect.width * 0.28,
            height: iconRect.height * 0.34
        )
        let shieldPath = shieldPath(in: shieldRect)
        NSColor(calibratedRed: 0.11, green: 0.22, blue: 0.34, alpha: 1).setFill()
        shieldPath.fill()

        let checkPath = NSBezierPath()
        checkPath.move(to: CGPoint(x: shieldRect.minX + shieldRect.width * 0.24, y: shieldRect.minY + shieldRect.height * 0.48))
        checkPath.line(to: CGPoint(x: shieldRect.minX + shieldRect.width * 0.43, y: shieldRect.minY + shieldRect.height * 0.28))
        checkPath.line(to: CGPoint(x: shieldRect.minX + shieldRect.width * 0.76, y: shieldRect.minY + shieldRect.height * 0.66))
        checkPath.lineCapStyle = .round
        checkPath.lineJoinStyle = .round
        checkPath.lineWidth = rect.width * 0.035
        NSColor.white.setStroke()
        checkPath.stroke()
    }

    private static func drawStatusIcon(in rect: CGRect) {
        guard let symbolImage = symbolImage(
            name: "hand.raised.fill",
            pointSize: rect.height * 0.94,
            weight: .regular,
            scale: .medium
        ) else {
            return
        }

        let symbolRect = rect.insetBy(dx: rect.width * 0.08, dy: rect.height * 0.06)
        symbolImage.draw(in: symbolRect)
    }

    private static func symbolImage(
        name: String,
        pointSize: CGFloat,
        weight: NSFont.Weight,
        scale: NSImage.SymbolScale
    ) -> NSImage? {
        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight, scale: scale)
        return NSImage(systemSymbolName: name, accessibilityDescription: "Mistouch Guard icon")?
            .withSymbolConfiguration(config)
    }

    private static func shieldPath(in rect: CGRect) -> NSBezierPath {
        let path = NSBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.line(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.18))
        path.line(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.minY + rect.height * 0.3))
        path.curve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            controlPoint1: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.minY + rect.height * 0.1),
            controlPoint2: CGPoint(x: rect.midX + rect.width * 0.15, y: rect.minY)
        )
        path.curve(
            to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.3),
            controlPoint1: CGPoint(x: rect.midX - rect.width * 0.15, y: rect.minY),
            controlPoint2: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.minY + rect.height * 0.1)
        )
        path.line(to: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.18))
        path.close()
        return path
    }
}
