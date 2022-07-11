//
//  SPISearchLaunchArguments.swift
//  SPISearch
//
//  Created by Joseph Heck on 7/10/22.
//

import ArgumentParser

struct SPISearchLaunchArguments: ParsableArguments {
    @Option(help: "Override the greeting name")
    var name: String?
}
