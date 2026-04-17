import AppKit

enum AppLogoPreview {
    static func makeImage(size: CGFloat = 768) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            drawLogo(in: rect)
            return true
        }
        image.isTemplate = false
        return image
    }

    private static func drawLogo(in rect: CGRect) {
        let base = min(rect.width, rect.height)
        let lineWidth = max(1.5, base * 0.045)

        let panelRect = rect.insetBy(dx: base * 0.08, dy: base * 0.12)
        let panelPath = NSBezierPath(roundedRect: panelRect, xRadius: base * 0.2, yRadius: base * 0.2)
        NSColor(calibratedRed: 0.09, green: 0.15, blue: 0.24, alpha: 1).setFill()
        panelPath.fill()
        NSColor(calibratedRed: 0.42, green: 0.76, blue: 0.97, alpha: 1).setStroke()
        panelPath.lineWidth = lineWidth
        panelPath.stroke()

        let topInset = panelRect.minY + panelRect.height * 0.2
        let keyHeight = panelRect.height * 0.12
        let keyWidth = panelRect.width * 0.18
        let keyGap = panelRect.width * 0.055
        let keyY = panelRect.maxY - topInset - keyHeight
        let keyStartX = panelRect.minX + panelRect.width * 0.14

        for index in 0..<3 {
            let x = keyStartX + CGFloat(index) * (keyWidth + keyGap)
            let keyRect = CGRect(x: x, y: keyY, width: keyWidth, height: keyHeight)
            let keyPath = NSBezierPath(roundedRect: keyRect, xRadius: keyHeight * 0.45, yRadius: keyHeight * 0.45)
            NSColor(calibratedRed: 0.77, green: 0.88, blue: 0.97, alpha: 1).setFill()
            keyPath.fill()
        }

        let shieldRect = CGRect(
            x: panelRect.maxX - panelRect.width * 0.4,
            y: panelRect.minY + panelRect.height * 0.16,
            width: panelRect.width * 0.28,
            height: panelRect.height * 0.42
        )
        let shieldPath = NSBezierPath()
        shieldPath.move(to: CGPoint(x: shieldRect.midX, y: shieldRect.maxY))
        shieldPath.line(to: CGPoint(x: shieldRect.maxX, y: shieldRect.maxY - shieldRect.height * 0.18))
        shieldPath.line(to: CGPoint(x: shieldRect.maxX - shieldRect.width * 0.06, y: shieldRect.minY + shieldRect.height * 0.28))
        shieldPath.curve(
            to: CGPoint(x: shieldRect.midX, y: shieldRect.minY),
            controlPoint1: CGPoint(x: shieldRect.maxX - shieldRect.width * 0.2, y: shieldRect.minY + shieldRect.height * 0.08),
            controlPoint2: CGPoint(x: shieldRect.midX + shieldRect.width * 0.14, y: shieldRect.minY)
        )
        shieldPath.curve(
            to: CGPoint(x: shieldRect.minX + shieldRect.width * 0.06, y: shieldRect.minY + shieldRect.height * 0.28),
            controlPoint1: CGPoint(x: shieldRect.midX - shieldRect.width * 0.14, y: shieldRect.minY),
            controlPoint2: CGPoint(x: shieldRect.minX + shieldRect.width * 0.2, y: shieldRect.minY + shieldRect.height * 0.08)
        )
        shieldPath.line(to: CGPoint(x: shieldRect.minX, y: shieldRect.maxY - shieldRect.height * 0.18))
        shieldPath.close()
        NSColor(calibratedRed: 0.13, green: 0.63, blue: 0.46, alpha: 1).setFill()
        shieldPath.fill()

        let handPath = NSBezierPath()
        handPath.lineCapStyle = .round
        handPath.lineJoinStyle = .round
        handPath.lineWidth = lineWidth * 0.92
        let palmBase = CGPoint(x: panelRect.minX + panelRect.width * 0.28, y: panelRect.minY + panelRect.height * 0.26)
        handPath.move(to: palmBase)
        handPath.curve(
            to: CGPoint(x: panelRect.minX + panelRect.width * 0.28, y: panelRect.minY + panelRect.height * 0.56),
            controlPoint1: CGPoint(x: panelRect.minX + panelRect.width * 0.2, y: panelRect.minY + panelRect.height * 0.34),
            controlPoint2: CGPoint(x: panelRect.minX + panelRect.width * 0.21, y: panelRect.minY + panelRect.height * 0.48)
        )
        handPath.move(to: CGPoint(x: panelRect.minX + panelRect.width * 0.22, y: panelRect.minY + panelRect.height * 0.54))
        handPath.line(to: CGPoint(x: panelRect.minX + panelRect.width * 0.22, y: panelRect.minY + panelRect.height * 0.76))
        handPath.move(to: CGPoint(x: panelRect.minX + panelRect.width * 0.3, y: panelRect.minY + panelRect.height * 0.58))
        handPath.line(to: CGPoint(x: panelRect.minX + panelRect.width * 0.3, y: panelRect.minY + panelRect.height * 0.81))
        handPath.move(to: CGPoint(x: panelRect.minX + panelRect.width * 0.38, y: panelRect.minY + panelRect.height * 0.54))
        handPath.line(to: CGPoint(x: panelRect.minX + panelRect.width * 0.38, y: panelRect.minY + panelRect.height * 0.74))
        handPath.move(to: CGPoint(x: panelRect.minX + panelRect.width * 0.45, y: panelRect.minY + panelRect.height * 0.48))
        handPath.line(to: CGPoint(x: panelRect.minX + panelRect.width * 0.45, y: panelRect.minY + panelRect.height * 0.64))
        NSColor.white.setStroke()
        handPath.stroke()

        let slashPath = NSBezierPath()
        slashPath.lineCapStyle = .round
        slashPath.lineWidth = lineWidth * 1.1
        slashPath.move(to: CGPoint(x: panelRect.minX + panelRect.width * 0.18, y: panelRect.minY + panelRect.height * 0.22))
        slashPath.line(to: CGPoint(x: panelRect.maxX - panelRect.width * 0.14, y: panelRect.maxY - panelRect.height * 0.18))
        NSColor(calibratedRed: 0.99, green: 0.55, blue: 0.27, alpha: 1).setStroke()
        slashPath.stroke()
    }
}

let outputURL = URL(fileURLWithPath: "/tmp/logo-preview.png")
let image = AppLogoPreview.makeImage()

guard
    let tiff = image.tiffRepresentation,
    let rep = NSBitmapImageRep(data: tiff),
    let png = rep.representation(using: .png, properties: [:])
else {
    fputs("Failed to encode preview image\n", stderr)
    exit(1)
}

try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try png.write(to: outputURL)
print(outputURL.path)
